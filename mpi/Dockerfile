FROM ubuntu:20.04

ENV DEBIAN_FRONTEND="noninteractive" TZ="MST"

RUN apt update && apt install -y openmpi-bin libopenmpi-dev openmpi-common openmpi-doc libopenmpi-dev mpich iproute2 nano iputils-ping openssh-server sudo libatlas-base-dev libblas-dev -y

RUN /usr/bin/ssh-keygen -A
RUN service ssh start
EXPOSE 22


RUN useradd -ms /bin/bash mpiuser
USER mpiuser
WORKDIR /home/mpiuser

RUN echo    "#include <mpi.h>\n" \
            "#include <stdio.h>\n" \
            "\n" \
            "int main(int argc, char** argv) {\n" \
            "    // Initialize the MPI environment\n" \
            "    MPI_Init(NULL, NULL);\n" \
            "\n" \
            "    // Get the number of processes\n" \
            "    int world_size;\n" \
            "    MPI_Comm_size(MPI_COMM_WORLD, &world_size);\n" \
            "\n" \
            "    // Get the rank of the process\n" \
            "    int world_rank;\n" \
            "    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);\n" \
            "\n" \
            "    // Get the name of the processor\n" \
            "    char processor_name[MPI_MAX_PROCESSOR_NAME];\n" \
            "    int name_len;\n" \
            "    MPI_Get_processor_name(processor_name, &name_len);\n" \
            "\n" \
            "    // Print off a hello world message\n" \
            "    printf(\"Hello world from processor %s, rank %d out of %d processors\\\\n \",\n" \
            "           processor_name, world_rank, world_size);\n" \
            "\n" \
            "    // Finalize the MPI environment.\n" \
            "    MPI_Finalize();\n" \
            "}\n" > mpi_hello_world.c

RUN mpicc mpi_hello_world.c -o hello-world

RUN mkdir /home/mpiuser/.ssh

COPY id_ed25519 /home/mpiuser/.ssh/id_ed25519
COPY id_ed25519.pub /home/mpiuser/.ssh/id_ed25519.pub
COPY hosts /home/mpiuser/hosts

RUN  echo   "Host *\n" \
            "  Port 22\n" \
            "  StrictHostKeyChecking no\n" \
            "  UserKnownHostsFile /dev/null\n"  \
            "  KexAlgorithms ecdh-sha2-nistp521"> /home/mpiuser/.ssh/config \
        && cat /home/mpiuser/.ssh/id_ed25519.pub > /home/mpiuser/.ssh/authorized_keys

USER root
# RUN cat /home/mpiuser/hosts >> /etc/hosts \
RUN chown mpiuser:mpiuser /home/mpiuser/.ssh/id_ed25519 \
        && chown mpiuser:mpiuser /home/mpiuser/.ssh/id_ed25519.pub \
        && chmod 400 /home/mpiuser/.ssh/id_ed25519 \
        && chmod 644 /home/mpiuser/.ssh/id_ed25519.pub \
        && chmod 600 /home/mpiuser/.ssh/authorized_keys

#CMD ["/usr/sbin/sshd","-D"]
ENTRYPOINT [ "/bin/sh", "-c", "cat /home/mpiuser/hosts >> /etc/hosts && /usr/sbin/sshd -D" ]
