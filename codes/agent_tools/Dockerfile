FROM --platform=linux/amd64 public.ecr.aws/lambda/python:3.11-x86_64


RUN yum update -y && \
    yum install -y python3 python3-dev python3-pip gcc && \
    rm -Rf /var/cache/yum

COPY requirements.txt ./
RUN pip3 install -r requirements.txt

COPY ./ ./



CMD ["lambda_app.lambda_handler"]