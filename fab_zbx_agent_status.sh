fab -H `cat hosts_agent|xargs|sed 's/ /,/g'` -f set_yunwei_fab.py zbx_agent_status |grep -E "running|stoped"|grep -vw run
