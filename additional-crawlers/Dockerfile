FROM python:3.6

ADD requirements.txt /
RUN pip install -r ./requirements.txt

ADD crawler.py /
ADD config.py /
ADD relevance.py /
ADD subscription.py /

CMD python -u ./crawler.py --log=INFO