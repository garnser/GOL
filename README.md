# GOL

How to use:
- Check out the full repo
git clone https://github.com/garnser/GOL.git
./generate.sh -n 3 -y
	      -n = no. web-nodes
	      -y = Bypass verification

Wait...

Once complete the LB will be at 192.168.10.10.

Check that the LB is working:
./verifylb.sh
  100 node1
  100 node2
  100 node3

