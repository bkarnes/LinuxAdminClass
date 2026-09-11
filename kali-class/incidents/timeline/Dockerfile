# Incident 4 — Timeline reconstruction
# Scenario: multiple suspicious events in a short window.
# Student skills: stat timestamps, log ordering, forensic thinking.
FROM ubuntu:22.04

RUN useradd -m student

RUN mkdir -p /incident \
    && touch -d "2026-01-10 03:10:00" /incident/a.txt \
    && touch -d "2026-01-10 03:10:30" /incident/b.txt \
    && touch -d "2026-01-10 03:11:00" /incident/c.txt \
    && touch -d "2026-01-10 03:12:00" /incident/.payload.sh \
    && printf '#!/bin/sh\n# planted during the 03:10-03:12 window\n' > /incident/.payload.sh \
    && chmod 700 /incident/.payload.sh

# A small app log that corroborates the file timestamps
RUN { echo "Jan 10 03:09:59 web01 app: normal startup"; \
      echo "Jan 10 03:10:02 web01 app: config write"; \
      echo "Jan 10 03:11:01 web01 app: config write"; \
      echo "Jan 10 03:12:05 web01 app: unknown process spawn"; \
    } > /var/log/applog

CMD ["sleep", "infinity"]