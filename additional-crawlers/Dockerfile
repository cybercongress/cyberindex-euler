FROM python:3.6

ENV DATABASE_HOST 172.28.1.2 
ENV HASURA_URL 172.28.1.3:8080

ADD requirements.txt /
RUN pip install -r ./requirements.txt

ADD crawler.py /
ADD config.py /
ADD relevance.py /
ADD bandwidth.py /
ADD subscription.py /

CMD python ./crawler.py