# Incident 1 — Authentication brute force
# Scenario: repeated failed SSH logins from one suspicious IP.
# Student skills: grep, less, wc -l, log interpretation.
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        openssh-server rsyslog \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m student && echo "student:student" | chpasswd \
    && useradd -m attacker \
    && mkdir -p /var/run/sshd /var/log

# Simulated auth.log with a brute-force pattern from one IP
RUN { echo "Jan 10 03:14:01 web01 sshd[1011]: Failed password for attacker from 10.10.10.5 port 4444 ssh2"; \
      echo "Jan 10 03:14:02 web01 sshd[1011]: Failed password for attacker from 10.10.10.5 port 4444 ssh2"; \
      echo "Jan 10 03:14:03 web01 sshd[1012]: Failed password for attacker from 10.10.10.5 port 4444 ssh2"; \
      echo "Jan 10 03:14:04 web01 sshd[1012]: Failed password for attacker from 10.10.10.5 port 4444 ssh2"; \
      echo "Jan 10 03:14:05 web01 sshd[1013]: Failed password for attacker from 10.10.10.5 port 4444 ssh2"; \
      echo "Jan 10 03:14:06 web01 sshd[1013]: Failed password for attacker from 10.10.10.5 port 4444 ssh2"; \
      echo "Jan 10 03:14:07 web01 sshd[1014]: Failed password for attacker from 10.10.10.5 port 4444 ssh2"; \
      echo "Jan 10 03:14:08 web01 sshd[1014]: Failed password for attacker from 10.10.10.5 port 4444 ssh2"; \
      echo "Jan 10 03:15:00 web01 sshd[1100]: Accepted password for student from 172.16.10.1 port 55022 ssh2"; \
      echo "Jan 10 03:20:00 web01 sshd[1200]: Failed password for invalid user admin from 172.16.10.99 port 5000 ssh2"; \
    } > /var/log/auth.log

# Keep the container alive for investigation
CMD ["sleep", "infinity"]