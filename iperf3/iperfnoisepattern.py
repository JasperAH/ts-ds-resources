import iperf3 #git@github.com:JasperAH/iperf3-python.git
import time
import sys

from numpy.random import normal

K = 1000
M = 1000000
G = 1000000000

def do_connect_cycle(duration=10,rate=0,server_hostname='localhost'):
    """
        :param duration: Duration of the connect cycle. Default: 10.
        :param rate: Traffic sending rate (bandwidth) in bits/sec. Default: 0 (unlimited).
        :param server_hostname: Hostname/IP of Iperf3 server.
        :type duration: integer or None
        :type rate: integer or None
        :type server_hostname: string or None
        :return: client run result
        :rtype: dict
    """
    client = iperf3.Client()

    client.server_hostname = server_hostname
    client.port = 5201
    client.bidirectional = True
    client.pacing_timer = 10000 # in microseconds

    client.duration = duration
    client.bandwidth = rate

    return client.run()

def run(max_linkspeed,connection_duration,connections,server_hostname):
    loc=max_linkspeed/2
    scale=G*2

    print("Time",",Sent_Mbps",",Received_Mbps", sep='')
    for i in range(connections):
        n = min(max_linkspeed,max(0,int(normal(loc=loc,scale=scale,size=1))))

        try:
            c = do_connect_cycle(duration=connection_duration,rate=n,server_hostname=server_hostname)
            print(time.time(), ",", c.sent_Mbps, ",", c.received_Mbps, sep='')
        except:
            print("[ERROR]: connect cycle failed.")

def main():
    max_linkspeed = 10*G            # linkspeed in bits/sec
    connection_duration=5          # connection duration in seconds
    connections = 12000                 # number of connections to execute
    server_hostname = "localhost"   # Hostname or IP of Iperf server
    if len(sys.argv) > 1:
        server_hostname = str(sys.argv[1])
    # Total duration = connections*connection_duration

    run(max_linkspeed=max_linkspeed,
        connection_duration=connection_duration,
        connections=connections,
        server_hostname=server_hostname)









if __name__ == "__main__":
    main()