# kali-class-privesc — dedicated privilege-escalation target for sec-wk10.
# A deliberately (but safely) misconfigured Ubuntu container students get a
# low-priv shell on, then escalate. Deployed by targets/blackhat-bash/deploy.sh
# alongside the BHB lab (same docker network).
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        nano findutils sudo openssh-server \
    && rm -rf /var/lib/apt/lists/*

# Low-priv user the student logs in as
RUN useradd -m -s /bin/bash intern && echo "intern:intern123" | chpasswd \
    && usermod -aG sudo intern

# --- Vector 1: SUID nano (classic GTFOBins: nano → spawner shell) ---
RUN cp /usr/bin/nano /usr/local/bin/nanohelp && chmod 4755 /usr/local/bin/nanohelp

# --- Vector 2: passwordless sudo find (GTFOBins) ---
RUN echo "intern ALL=(root) NOPASSWD: /usr/bin/find" > /etc/sudoers.d/intern-find \
    && chmod 440 /etc/sudoers.d/intern-find

# --- Vector 3: writable /etc/passwd (full compromise) ---
RUN chmod 666 /etc/passwd

# A readable "hint" file for students
RUN mkdir -p /opt/notes && echo \
    "Reminder from admin: we gave nano SUID by mistake (nanohelp).\n" \
    "Also intern can run find without a password — need to fix that." \
    > /opt/notes/admin-todo.txt && chown -R root:root /opt/notes

# Capstone flag placeholder (seeded by seed-flags.sh at runtime)
RUN mkdir -p /root && echo "placeholder" > /root/flag.txt && chmod 600 /root/flag.txt

RUN mkdir /var/run/sshd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]