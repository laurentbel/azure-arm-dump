FROM mcr.microsoft.com/azure-cli

WORKDIR /app
COPY main.sh .

CMD [ "/app/main.sh" ]