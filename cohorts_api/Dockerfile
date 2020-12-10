FROM python:3.6

ADD requirements.txt /
RUN pip install -r ./requirements.txt

ADD app.py /
ADD cohort.py /
ADD config.py /
ADD queries.py /

CMD python ./app.py