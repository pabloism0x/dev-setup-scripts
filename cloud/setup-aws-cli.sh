#!/bin/bash

# AWS CLI 및 도구 설치 스크립트
# 작성자: pabloism0x

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 시작 메시지
echo "========================================"
echo "  AWS CLI 및 도구 설치 스크립트"
echo "========================================"
echo ""

# 운영체제 및 아키텍처 감지
detect_system() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        OS=Debian
        VER=$(cat /etc/debian_version)
    elif [ -f /etc/redhat-release ]; then
        OS=RedHat
        VER=$(cat /etc/redhat-release)
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    
    # 아키텍처 감지
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) AWS_ARCH="x86_64" ;;
        aarch64|arm64) AWS_ARCH="aarch64" ;;
        *) 
            log_error "지원하지 않는 아키텍처입니다: $ARCH"
            exit 1
            ;;
    esac
}

# 의존성 패키지 설치
install_dependencies() {
    detect_system
    log_info "감지된 운영체제: $OS $VER ($ARCH)"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        # Ubuntu/Debian
        log_info "의존성 패키지 설치 중..."
        sudo apt install -y curl wget unzip python3 python3-pip groff less
        
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]] || [[ "$OS" == *"AlmaLinux"* ]]; then
        # RHEL 계열
        log_info "의존성 패키지 설치 중..."
        if command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y curl wget unzip python3 python3-pip groff less
        else
            sudo yum install -y curl wget unzip python3 python3-pip groff less
        fi
        
    elif [[ "$OS" == *"Fedora"* ]]; then
        # Fedora
        log_info "의존성 패키지 설치 중..."
        sudo dnf install -y curl wget unzip python3 python3-pip groff less
        
    elif [[ "$OS" == *"openSUSE"* ]] || [[ "$OS" == *"SUSE"* ]]; then
        # openSUSE
        log_info "의존성 패키지 설치 중..."
        sudo zypper install -y curl wget unzip python3 python3-pip groff less
        
    elif [[ "$OS" == *"Arch"* ]] || [[ "$OS" == *"Manjaro"* ]]; then
        # Arch 계열
        log_info "의존성 패키지 설치 중..."
        sudo pacman -S --noconfirm curl wget unzip python python-pip groff less
        
    elif [[ "$OS" == *"Alpine"* ]]; then
        # Alpine
        log_info "의존성 패키지 설치 중..."
        sudo apk add curl wget unzip python3 py3-pip groff less
        
    else
        log_warning "지원하지 않는 운영체제입니다: $OS"
        log_info "의존성 패키지를 수동으로 설치해주세요: curl, wget, unzip, python3, pip"
    fi
}

# 패키지 목록 업데이트
log_info "패키지 목록 업데이트 중..."
if command -v apt >/dev/null 2>&1; then
    sudo apt update
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf check-update || true
elif command -v yum >/dev/null 2>&1; then
    sudo yum check-update || true
elif command -v zypper >/dev/null 2>&1; then
    sudo zypper refresh
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy
elif command -v apk >/dev/null 2>&1; then
    sudo apk update
fi

# 의존성 패키지 설치
install_dependencies

# AWS CLI v2 설치
log_info "AWS CLI v2 설치 중..."
if ! command -v aws >/dev/null 2>&1; then
    cd /tmp
    
    # AWS CLI v2 다운로드
    AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip"
    log_info "AWS CLI 다운로드 중: $AWS_CLI_URL"
    curl -L "$AWS_CLI_URL" -o "awscliv2.zip"
    
    # 압축 해제 및 설치
    unzip -q awscliv2.zip
    sudo ./aws/install
    
    # 정리
    rm -rf awscliv2.zip aws/
    
    log_success "AWS CLI v2 설치 완료"
else
    log_info "AWS CLI가 이미 설치되어 있습니다"
fi

# AWS CLI 버전 확인
AWS_VERSION=$(aws --version)
log_success "AWS CLI 설치 확인: $AWS_VERSION"

# Session Manager Plugin 설치
log_info "AWS Session Manager Plugin 설치 중..."
if ! command -v session-manager-plugin >/dev/null 2>&1; then
    cd /tmp
    
    if [[ "$AWS_ARCH" == "x86_64" ]]; then
        SM_URL="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb"
        wget -q "$SM_URL"
        sudo dpkg -i session-manager-plugin.deb 2>/dev/null || sudo rpm -i session-manager-plugin.rpm 2>/dev/null || {
            # 수동 설치 (패키지 매니저가 없는 경우)
            SM_URL="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm"
            wget -q "$SM_URL"
            rpm2cpio session-manager-plugin.rpm | cpio -idmv
            sudo cp usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/
            sudo chmod +x /usr/local/bin/session-manager-plugin
        }
    else
        SM_URL="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_arm64/session-manager-plugin.rpm"
        wget -q "$SM_URL"
        sudo rpm -i session-manager-plugin.rpm 2>/dev/null || {
            rpm2cpio session-manager-plugin.rpm | cpio -idmv
            sudo cp usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/
            sudo chmod +x /usr/local/bin/session-manager-plugin
        }
    fi
    
    rm -f session-manager-plugin.*
    log_success "Session Manager Plugin 설치 완료"
else
    log_info "Session Manager Plugin이 이미 설치되어 있습니다"
fi

# AWS CDK 설치
log_info "AWS CDK 설치 중..."
if command -v npm >/dev/null 2>&1; then
    sudo npm install -g aws-cdk
    log_success "AWS CDK 설치 완료"
else
    log_warning "Node.js/npm이 설치되지 않아 AWS CDK를 건너뜁니다"
fi

# AWS SAM CLI 설치
log_info "AWS SAM CLI 설치 중..."
if ! command -v sam >/dev/null 2>&1; then
    cd /tmp
    
    # SAM CLI 다운로드
    if [[ "$AWS_ARCH" == "x86_64" ]]; then
        SAM_URL="https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip"
    else
        SAM_URL="https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-arm64.zip"
    fi
    
    wget -q "$SAM_URL" -O aws-sam-cli.zip
    unzip -q aws-sam-cli.zip -d sam-installation
    sudo ./sam-installation/install
    
    rm -rf aws-sam-cli.zip sam-installation/
    log_success "AWS SAM CLI 설치 완료"
else
    log_info "AWS SAM CLI가 이미 설치되어 있습니다"
fi

# AWS Copilot 설치
log_info "AWS Copilot 설치 중..."
if ! command -v copilot >/dev/null 2>&1; then
    cd /tmp
    
    # Copilot 다운로드
    if [[ "$AWS_ARCH" == "x86_64" ]]; then
        COPILOT_URL="https://github.com/aws/copilot-cli/releases/latest/download/copilot-linux"
    else
        COPILOT_URL="https://github.com/aws/copilot-cli/releases/latest/download/copilot-linux-arm64"
    fi
    
    wget -q "$COPILOT_URL" -O copilot
    chmod +x copilot
    sudo mv copilot /usr/local/bin/
    
    log_success "AWS Copilot 설치 완료"
else
    log_info "AWS Copilot이 이미 설치되어 있습니다"
fi

# Terraform 설치 (AWS 인프라 관리용)
log_info "Terraform 설치 중..."
if ! command -v terraform >/dev/null 2>&1; then
    cd /tmp
    
    # Terraform 최신 버전 확인
    TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
    
    if [[ "$AWS_ARCH" == "x86_64" ]]; then
        TF_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
    else
        TF_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_arm64.zip"
    fi
    
    wget -q "$TF_URL" -O terraform.zip
    unzip -q terraform.zip
    sudo mv terraform /usr/local/bin/
    
    rm -f terraform.zip
    log_success "Terraform 설치 완료"
else
    log_info "Terraform이 이미 설치되어 있습니다"
fi

# 작업 디렉토리 생성
log_info "AWS 작업 디렉토리 생성 중..."
mkdir -p ~/workspace/aws
mkdir -p ~/workspace/aws/cdk
mkdir -p ~/workspace/aws/sam
mkdir -p ~/workspace/aws/terraform
mkdir -p ~/workspace/aws/cloudformation
mkdir -p ~/.aws

# .bashrc에 AWS 관련 설정 추가
log_info "AWS 관련 환경 설정 추가 중..."
cat >> ~/.bashrc << 'BASHRC_EOF'

# ======================================
# AWS 개발 환경 설정
# ======================================

# AWS CLI 자동완성
complete -C '/usr/local/bin/aws_completer' aws

# AWS 환경 변수
export AWS_PAGER=""
export AWS_DEFAULT_OUTPUT="table"

# AWS alias
alias awsprofile='aws configure list-profiles'
alias awswhoami='aws sts get-caller-identity'
alias awsregion='aws configure get region'
alias awslogin='aws sso login'
alias awslogout='aws sso logout'

# AWS 리소스 관리 alias
alias ec2list='aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,Tags[?Key==\`Name\`].Value|[0]]" --output table'
alias s3list='aws s3 ls'
alias rdslist='aws rds describe-db-instances --query "DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Engine,DBInstanceClass,Endpoint.Address]" --output table'
alias lambdalist='aws lambda list-functions --query "Functions[*].[FunctionName,Runtime,LastModified]" --output table'

# CDK alias
alias cdkdiff='cdk diff'
alias cdkdeploy='cdk deploy'
alias cdkdestroy='cdk destroy'
alias cdksynth='cdk synth'

# SAM alias
alias sambuild='sam build'
alias samdeploy='sam deploy --guided'
alias samlocal='sam local start-api'

# Terraform alias
alias tfinit='terraform init'
alias tfplan='terraform plan'
alias tfapply='terraform apply'
alias tfdestroy='terraform destroy'
alias tfvalidate='terraform validate'
alias tfformat='terraform fmt'

# AWS 프로필 관리 함수
awsuse() {
    if [ $# -eq 0 ]; then
        echo "사용법: awsuse <프로필명>"
        echo "사용 가능한 프로필:"
        aws configure list-profiles
        return 1
    fi
    
    export AWS_PROFILE="$1"
    echo "✅ AWS 프로필 '$1' 활성화"
    echo "현재 사용자: $(aws sts get-caller-identity --query 'Arn' --output text 2>/dev/null || echo '인증 필요')"
}

# AWS 리전 변경 함수
awsregion() {
    if [ $# -eq 0 ]; then
        echo "현재 리전: $(aws configure get region)"
        echo ""
        echo "주요 AWS 리전:"
        echo "  us-east-1      (N. Virginia)"
        echo "  us-west-2      (Oregon)"
        echo "  eu-west-1      (Ireland)"
        echo "  ap-northeast-1 (Tokyo)"
        echo "  ap-northeast-2 (Seoul)"
        echo "  ap-southeast-1 (Singapore)"
        return 0
    fi
    
    aws configure set region "$1"
    echo "✅ AWS 리전을 '$1'로 변경했습니다"
}

# AWS 계정 정보 확인 함수
awsinfo() {
    echo "=== AWS 계정 정보 ==="
    
    # 현재 사용자 정보
    echo "현재 사용자:"
    aws sts get-caller-identity 2>/dev/null || echo "인증이 필요합니다 (aws configure 또는 aws sso login)"
    echo ""
    
    # 현재 설정
    echo "현재 설정:"
    echo "프로필: ${AWS_PROFILE:-default}"
    echo "리전: $(aws configure get region)"
    echo "출력 형식: $(aws configure get output)"
    echo ""
    
    # 사용 가능한 프로필
    echo "사용 가능한 프로필:"
    aws configure list-profiles
}

# AWS 리소스 요약 함수
awssummary() {
    echo "=== AWS 리소스 요약 ==="
    echo ""
    
    echo "🖥️  EC2 인스턴스:"
    aws ec2 describe-instances --query 'length(Reservations[*].Instances[*])' --output text 2>/dev/null || echo "조회 실패"
    echo ""
    
    echo "💾 S3 버킷:"
    aws s3 ls | wc -l 2>/dev/null || echo "조회 실패"
    echo ""
    
    echo "🗄️  RDS 인스턴스:"
    aws rds describe-db-instances --query 'length(DBInstances)' --output text 2>/dev/null || echo "조회 실패"
    echo ""
    
    echo "⚡ Lambda 함수:"
    aws lambda list-functions --query 'length(Functions)' --output text 2>/dev/null || echo "조회 실패"
    echo ""
    
    echo "🌐 CloudFormation 스택:"
    aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query 'length(StackSummaries)' --output text 2>/dev/null || echo "조회 실패"
}

# AWS 비용 확인 함수 (Cost Explorer API 필요)
awscost() {
    local start_date="${1:-$(date -d '30 days ago' +%Y-%m-%d)}"
    local end_date="${2:-$(date +%Y-%m-%d)}"
    
    echo "💰 AWS 비용 정보 ($start_date ~ $end_date):"
    aws ce get-cost-and-usage \
        --time-period Start="$start_date",End="$end_date" \
        --granularity MONTHLY \
        --metrics BlendedCost \
        --query 'ResultsByTime[*].[TimePeriod.Start,Total.BlendedCost.Amount]' \
        --output table 2>/dev/null || echo "Cost Explorer API 액세스 권한이 필요합니다"
}

# AWS 프로젝트 초기화 함수
awsinit() {
    if [ $# -eq 0 ]; then
        echo "사용법: awsinit <프로젝트명> [프로젝트타입]"
        echo "프로젝트 타입: cdk, sam, terraform, cloudformation"
        return 1
    fi
    
    local project_name="$1"
    local project_type="${2:-cdk}"
    
    case "$project_type" in
        "cdk")
            mkdir -p ~/workspace/aws/cdk/"$project_name"
            cd ~/workspace/aws/cdk/"$project_name"
            
            if command -v cdk >/dev/null 2>&1; then
                cdk init app --language typescript
                echo "✅ CDK 프로젝트 '$project_name' 생성 완료"
            else
                echo "❌ CDK가 설치되지 않았습니다"
            fi
            ;;
        "sam")
            mkdir -p ~/workspace/aws/sam/"$project_name"
            cd ~/workspace/aws/sam/"$project_name"
            
            if command -v sam >/dev/null 2>&1; then
                sam init --name "$project_name" --runtime nodejs18.x --architecture x86_64 --app-template hello-world
                echo "✅ SAM 프로젝트 '$project_name' 생성 완료"
            else
                echo "❌ SAM CLI가 설치되지 않았습니다"
            fi
            ;;
        "terraform")
            mkdir -p ~/workspace/aws/terraform/"$project_name"
            cd ~/workspace/aws/terraform/"$project_name"
            
            # 기본 Terraform 파일들 생성
            cat > main.tf << 'TF_EOF'
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 변수 정의
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# 리소스 예시
# resource "aws_s3_bucket" "example" {
#   bucket = "${var.environment}-${var.project_name}-bucket"
# }
TF_EOF

            cat > variables.tf << 'VAR_EOF'
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "my-project"
}
VAR_EOF

            cat > outputs.tf << 'OUT_EOF'
# output "bucket_name" {
#   description = "Name of the S3 bucket"
#   value       = aws_s3_bucket.example.bucket
# }
OUT_EOF

            echo "✅ Terraform 프로젝트 '$project_name' 생성 완료"
            ;;
        "cloudformation")
            mkdir -p ~/workspace/aws/cloudformation/"$project_name"
            cd ~/workspace/aws/cloudformation/"$project_name"
            
            cat > template.yaml << 'CF_EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'CloudFormation template for PROJECT_NAME'

Parameters:
  Environment:
    Type: String
    Default: dev
    Description: Environment name

Resources:
  # 예시 S3 버킷
  # MyS3Bucket:
  #   Type: AWS::S3::Bucket
  #   Properties:
  #     BucketName: !Sub '${Environment}-${AWS::StackName}-bucket'

Outputs:
  # BucketName:
  #   Description: 'S3 Bucket Name'
  #   Value: !Ref MyS3Bucket
  #   Export:
  #     Name: !Sub '${AWS::StackName}-BucketName'
CF_EOF

            echo "✅ CloudFormation 프로젝트 '$project_name' 생성 완료"
            ;;
        *)
            echo "❌ 지원하지 않는 프로젝트 타입입니다: $project_type"
            echo "사용 가능한 타입: cdk, sam, terraform, cloudformation"
            ;;
    esac
}

BASHRC_EOF

# AWS CLI 설정 도우미 스크립트 생성
log_info "AWS 설정 도우미 스크립트 생성 중..."
cat > ~/workspace/aws/aws-setup-helper.sh << 'HELPER_EOF'
#!/bin/bash

# AWS CLI 설정 도우미 스크립트

echo "========================================"
echo "  AWS CLI 설정 도우미"
echo "========================================"
echo ""

echo "1. AWS CLI 기본 설정"
echo "2. AWS SSO 설정"
echo "3. AWS 프로필 추가"
echo "4. 설정 확인"
echo ""

read -p "선택하세요 (1-4): " choice

case $choice in
    1)
        echo "AWS CLI 기본 설정을 시작합니다..."
        aws configure
        ;;
    2)
        echo "AWS SSO 설정을 시작합니다..."
        read -p "SSO 시작 URL을 입력하세요: " sso_url
        read -p "SSO 리전을 입력하세요 (예: ap-northeast-2): " sso_region
        read -p "프로필 이름을 입력하세요: " profile_name
        
        aws configure sso \
            --profile "$profile_name" \
            --sso-start-url "$sso_url" \
            --sso-region "$sso_region"
        ;;
    3)
        echo "새 AWS 프로필을 추가합니다..."
        read -p "프로필 이름을 입력하세요: " profile_name
        aws configure --profile "$profile_name"
        ;;
    4)
        echo "현재 AWS 설정:"
        echo ""
        echo "=== 프로필 목록 ==="
        aws configure list-profiles
        echo ""
        echo "=== 현재 설정 ==="
        aws configure list
        echo ""
        echo "=== 현재 사용자 ==="
        aws sts get-caller-identity 2>/dev/null || echo "인증이 필요합니다"
        ;;
    *)
        echo "잘못된 선택입니다."
        ;;
esac
HELPER_EOF

chmod +x ~/workspace/aws/aws-setup-helper.sh

# AWS 개발 템플릿 생성
log_info "AWS 개발 템플릿 생성 중..."
mkdir -p ~/workspace/aws/templates

# Lambda 함수 템플릿 (Node.js)
cat > ~/workspace/aws/templates/lambda-nodejs.js << 'LAMBDA_EOF'
const AWS = require('aws-sdk');

exports.handler = async (event, context) => {
    console.log('Event:', JSON.stringify(event, null, 2));
    console.log('Context:', JSON.stringify(context, null, 2));
    
    try {
        // 여기에 비즈니스 로직 구현
        const result = {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                message: 'Hello from Lambda!',
                timestamp: new Date().toISOString(),
                event: event
            })
        };
        
        return result;
    } catch (error) {
        console.error('Error:', error);
        
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                error: 'Internal Server Error',
                message: error.message
            })
        };
    }
};
LAMBDA_EOF

# Lambda 함수 템플릿 (Python)
cat > ~/workspace/aws/templates/lambda-python.py << 'LAMBDA_PY_EOF'
import json
import boto3
import logging
from datetime import datetime

# 로깅 설정
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    AWS Lambda 함수 핸들러
    """
    logger.info(f"Event: {json.dumps(event)}")
    logger.info(f"Context: {context}")
    
    try:
        # 여기에 비즈니스 로직 구현
        result = {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Hello from Lambda!',
                'timestamp': datetime.now().isoformat(),
                'event': event
            })
        }
        
        return result
        
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal Server Error',
                'message': str(e)
            })
        }
LAMBDA_PY_EOF

# API Gateway + Lambda SAM 템플릿
cat > ~/workspace/aws/templates/sam-template.yaml << 'SAM_EOF'
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: 'SAM Template for API Gateway + Lambda'

Globals:
  Function:
    Timeout: 30
    Runtime: nodejs18.x
    Environment:
      Variables:
        NODE_ENV: !Ref Environment

Parameters:
  Environment:
    Type: String
    Default: dev
    AllowedValues: [dev, staging, prod]

Resources:
  # API Gateway
  MyApi:
    Type: AWS::Serverless::Api
    Properties:
      StageName: !Ref Environment
      Cors:
        AllowMethods: "'GET,POST,PUT,DELETE,OPTIONS'"
        AllowHeaders: "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
        AllowOrigin: "'*'"

  # Lambda Function
  MyFunction:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: !Sub '${AWS::StackName}-function'
      CodeUri: src/
      Handler: index.handler
      Events:
        GetApi:
          Type: Api
          Properties:
            RestApiId: !Ref MyApi
            Path: /hello
            Method: GET
        PostApi:
          Type: Api
          Properties:
            RestApiId: !Ref MyApi
            Path: /hello
            Method: POST

  # DynamoDB Table (선택사항)
  MyTable:
    Type: AWS::Serverless::SimpleTable
    Properties:
      TableName: !Sub '${AWS::StackName}-table'
      PrimaryKey:
        Name: id
        Type: String

Outputs:
  ApiUrl:
    Description: 'API Gateway URL'
    Value: !Sub 'https://${MyApi}.execute-api.${AWS::Region}.amazonaws.com/${Environment}/'
    Export:
      Name: !Sub '${AWS::StackName}-ApiUrl'
      
  FunctionArn:
    Description: 'Lambda Function ARN'
    Value: !GetAtt MyFunction.Arn
    Export:
      Name: !Sub '${AWS::StackName}-FunctionArn'
SAM_EOF

# 완료 메시지
echo ""
echo "========================================"
echo "  AWS CLI 및 도구 설치 완료!"
echo "========================================"
echo "AWS CLI 버전: $(aws --version)"
if command -v cdk >/dev/null 2>&1; then
    echo "AWS CDK 버전: $(cdk --version)"
fi
if command -v sam >/dev/null 2>&1; then
    echo "AWS SAM CLI 버전: $(sam --version)"
fi
if command -v terraform >/dev/null 2>&1; then
    echo "Terraform 버전: $(terraform --version | head -n1)"
fi
if command -v copilot >/dev/null 2>&1; then
    echo "AWS Copilot 버전: $(copilot --version)"
fi
echo ""
echo "📁 작업 디렉토리:"
echo "  • ~/workspace/aws/ - AWS 프로젝트들"
echo "  • ~/workspace/aws/cdk/ - CDK 프로젝트들"
echo "  • ~/workspace/aws/sam/ - SAM 프로젝트들"
echo "  • ~/workspace/aws/terraform/ - Terraform 프로젝트들"
echo "  • ~/workspace/aws/templates/ - 개발 템플릿들"
echo ""
echo "🔧 사용 가능한 명령어:"
echo "  • awsinfo - AWS 계정 정보"
echo "  • awsuse <프로필> - AWS 프로필 변경"
echo "  • awsregion [리전] - AWS 리전 확인/변경"
echo "  • awssummary - AWS 리소스 요약"
echo "  • awsinit <프로젝트명> [타입] - 새 프로젝트 초기화"
echo ""
echo "📋 다음 명령어로 환경 변수를 적용하세요:"
echo "source ~/.bashrc"
echo ""
echo "⚙️  AWS CLI 설정:"
echo "1. 기본 설정: aws configure"
echo "2. SSO 설정: aws configure sso"
echo "3. 설정 도우미: ~/workspace/aws/aws-setup-helper.sh"
echo ""
echo "🧪 테스트 명령어:"
echo "aws sts get-caller-identity"
echo "awsinit my-first-project cdk"
echo "========================================"