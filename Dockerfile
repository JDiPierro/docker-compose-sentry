FROM sentry

RUN apt-get update && apt-get install -y netcat

COPY run.sh /startup/run.sh

ENTRYPOINT ["/bin/bash"]
CMD ["/startup/run.sh"]