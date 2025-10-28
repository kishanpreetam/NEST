#!/bin/bash
# Deploy all 10 crisis response agents

API_KEY="$1"
CONFIG_FILE="scripts/agent_configs/group-crisis-flood-response.json"
REGISTRY_URL="http://capregistry.duckdns.org:6900"
SERVER_IP="45.79.137.119"

# Read each agent from config and start it
python3 << PYEOF
import json
import subprocess
import time

with open("$CONFIG_FILE") as f:
    agents = json.load(f)

for agent in agents:
    port = agent['port']
    
    # Set environment variables and start agent
    env = {
        'ANTHROPIC_API_KEY': '$API_KEY',
        'AGENT_ID': agent['agent_id'],
        'AGENT_NAME': agent['agent_name'],
        'AGENT_DOMAIN': agent['domain'],
        'AGENT_SPECIALIZATION': agent['specialization'],
        'AGENT_DESCRIPTION': agent['description'],
        'AGENT_CAPABILITIES': agent['capabilities'],
        'SYSTEM_PROMPT': agent['system_prompt'],
        'REGISTRY_URL': '$REGISTRY_URL',
        'PUBLIC_URL': f'http://$SERVER_IP:{port}',
        'PORT': str(port)
    }
    
    # Start agent in background
    subprocess.Popen(
        ['python3', 'examples/nanda_agent.py'],
        env={**subprocess.os.environ, **env},
        stdout=open(f'logs/agent_{agent["agent_id"]}.log', 'w'),
        stderr=subprocess.STDOUT
    )
    
    print(f"✅ Started {agent['agent_name']} on port {port}")
    time.sleep(3)

print("\n🎉 All 10 agents started!")
PYEOF
