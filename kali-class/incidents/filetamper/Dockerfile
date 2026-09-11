# Incident 2 — Unauthorized file modification
# Scenario: a config file was modified outside change control.
# Student skills: ls -l, stat, chmod, chown, risk reasoning.
FROM ubuntu:22.04

RUN useradd -m student

RUN mkdir -p /srv/grades \
    && echo "student_id,grade" > /srv/grades/final.csv \
    && echo "901234567,B" >> /srv/grades/final.csv \
    && chown root:root /srv/grades/final.csv \
    && chmod 600 /srv/grades/final.csv

# Simulate tampering: content changed + permissions opened up + owner flipped
RUN echo "901234567,A+,MODIFIED" >> /srv/grades/final.csv \
    && chmod 777 /srv/grades/final.csv \
    && chown nobody:nogroup /srv/grades/final.csv

# Timestamp reference file (untouched, for comparison)
RUN touch -d "2026-01-09 09:00" /srv/grades/.baseline

CMD ["sleep", "infinity"]