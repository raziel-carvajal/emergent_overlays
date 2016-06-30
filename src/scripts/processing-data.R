
# ============================================
# Broadcast Time
# For each message sent from the source, we need to figure out how long it took to
# receive the message for the first time in all nodes (or all nodes that actually received)
#
# Steps:
#   1. Identify source of messages (node name)
#   2. Identify set of message sent (a table with two columns: message id, sent time)
#   3. For m in "message sent" 
#   3.    For n in nodes do
#   4.       messages-received = load messages received in that node (broadcast_msg_received)
#   5.       time = pick msg.time from message-received such that msg.id = m.id and (msg.time <= msg2.time for all msg2 in messages-received)
#   6.       results[n][m.id] = m.time - time
#
# Result
# A 2d matrix indexed by node and message id
#         m0   m1   m2
# node0  1.4  2.1  2.3
# node1  1.7  1.8  2.5
# node2  1.8  1.7  1.5
#
#

path_to_results <- "~/work/src/infocom2017/experiments/configs/results/nodes200-abba2-300broadcasts-highdensity-0/"
source <- "hostR0"

p <- paste(path_to_results, source, "-msg_sent", sep = "", collapse = "")

messages_sent <- read.table(p, quote = "\"", comment.char = "")

battery_level <- read.table(paste(path_to_results, source,"-power_level", sep=""))

printf <- function(...) invisible(cat(sprintf(...)))

sss <- apply(messages_sent, c(1,2), sum)
print(sss)

# ============================================
# Broadcast Number of Duplicated Messages
# For each message sent from the source, we need to figure out how many times a message
# is received
#
# Steps:
#   1. Identify source of messages (node name)
#   2. Identify set of message sent (a table with two columns: message id, sent time)
#   3. For m in "message sent" 
#   3.    For n in nodes do
#   4.       messages-received = load messages received in that node (broadcast_msg_received)
#   5.       n = count msg in messages_received such that m.id == msg.id 
#   6.       results[n][m.id] = n
#
# Result
# A 2d matrix indexed by node and message id
#         m0   m1   m2
# node0  1.4  2.1  2.3
# node1  1.7  1.8  2.5
# node2  1.8  1.7  1.5
#
#


# ============================================
# Battery Level for a node
# For each message sent from the source, we need to figure out how long it took to
# receive the message for the first time in all nodes (or all nodes that actually received)
#
# Steps:
#   1. Identify source of messages (node name)
#   2. Identify set of message sent (a table with two columns: message id, sent time)
#   3. For m in "message sent" 
#   3.    For n in nodes do
#   4.       messages-received = load messages received in that node (broadcast_msg_received)
#   5.       time = pick msg.time from message-received such that msg.id = m.id and (msg.time <= msg2.time for all msg2 in messages-received)
#   6.       results[n][m.id] = m.time - time
#
# Result
# A 2d matrix indexed by node and message id
#         node0
# node0  1.4  2.1  2.3
# node1  1.7  1.8  2.5
# node2  1.8  1.7  1.5
#
#
