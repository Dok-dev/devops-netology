FROM fedora
RUN dnf -y update && \
	dnf -y install jq && \
    dnf -y install pip && \
    pip install -q hvac
ENTRYPOINT ["sh"]