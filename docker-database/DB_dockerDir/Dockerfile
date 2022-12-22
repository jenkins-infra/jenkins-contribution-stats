FROM postgres:15-alpine

COPY *.sql /docker-entrypoint-initdb.d/
# why does the example have these two "equivalent" syntaxes 
ADD setup.sql /docker-entrypoint-initdb.d

RUN chmod a+r /docker-entrypoint-initdb.d/*

# Make the raw datafile available in the image so that it can be loaded by the
# SQL init script
ADD submissions.csv /tmp/
RUN chmod a+r /tmp/submissions.csv
