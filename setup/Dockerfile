ARG BUILD_FROM
FROM $BUILD_FROM as builder

RUN apk update && apk add --no-cache \
	vim \
	wireless-tools \
	wpa_supplicant

WORKDIR /tmp

COPY run.sh /opt
RUN chmod a+x /opt/run.sh

CMD [ "/opt/run.sh" ]
