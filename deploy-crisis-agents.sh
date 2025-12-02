
API_KEY="$1"
CONFIG_FILE="scripts/agent_configs/group-crisis-flood-response.json"
REGISTRY_URL="http://45.79.143.96:6900"
SERVER_IP="66.228.36.80"

if [ -z "$API_KEY" ]; then
    echo "❌ Error: API key required"
    echo "Usage: $0 YOUR_ANTHROPIC_API_KEY"
    exit 1
fi

echo "🚀 Deploying 10 NANDA Crisis Response Agents..."
echo "📍 Registry: $REGISTRY_URL"
echo "🌐 Server IP: $SERVER_IP"
echo ""

python3 << PYEOF
import json
import subprocess
import time
import os

with open("$CONFIG_FILE") as f:
    agents = json.load(f)

os.makedirs('logs', exist_ok=True)

for agent in agents:
    port = agent['port']
    
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
    
    subprocess.Popen(
        ['python3', 'examples/nanda_agent.py'],
        env={**os.environ, **env},
        stdout=open(f'logs/agent_{agent["agent_id"]}.log', 'w'),
        stderr=subprocess.STDOUT
    )
    
    print(f"✅ Started {agent['agent_name']} on port {port}")
    time.sleep(2)

print("\n🎉 All 10 agents started!")
print("\n📊 View in registry: http://45.79.143.96:9000/registry_ui.html")
PYEOF
