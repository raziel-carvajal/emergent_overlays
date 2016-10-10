
f = open('log_file_mwst.txt')
lines = list(f)
f.close()

sent = filter( ( lambda e: e.split(' ')[0] == 'Sending'  ) , lines )
received = filter( ( lambda e: e.split(' ')[0] == 'Received' ) , lines )

ss = map( (lambda x:  ( x.split(' ')[0], x.split(' ')[1], x.split(' ')[2], x.split(' ')[3],  float(x.split(' ')[4]), x.split(' ')[5:8] )  ), sent  )
rr = map( (lambda x:  ( x.split(' ')[0], x.split(' ')[1], x.split(' ')[2], x.split(' ')[3],  float(x.split(' ')[4]), x.split(' ')[5:8] )  ), received  )

def was_received(m, rr):
    for a in rr:
        if m[1] == a[1] and m[3] == a[2] and m[2] == a[3] and a[4] - m[4] < 0.3:
                print "Sending", m
                print "Receiving", a
                print "========================="
                return True
    print "\n  ERROR:  \n", m
    return False


map( ( lambda m: was_received(m, rr) ) , ss)
