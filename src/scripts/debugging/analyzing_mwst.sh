cat log_file_mwst.txt | grep 'Sending Test' | grep 'now = 1' | awk -F '[' '{ print , ,  }'
cat log_file_mwst.txt  | grep Test Received | awk -F '[' '{print , , }'
