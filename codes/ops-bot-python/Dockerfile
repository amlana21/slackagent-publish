FROM public.ecr.aws/lambda/python:3.11.2025.06.19.12-x86_64

RUN yum update -y && \
    yum install -y python3 python3-dev python3-pip gcc && \
    rm -Rf /var/cache/yum

COPY requirements.txt ./
RUN pip3 install -r requirements.txt
COPY lambda_app.py ./


# Points to the handler function of your lambda function
CMD ["lambda_app.lambda_handler"]