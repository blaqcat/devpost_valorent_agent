import streamlit as st
import boto3
import re
import os
from botocore.exceptions import ClientError
import xml.etree.ElementTree as ET

# Set up AWS credentials
AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.environ.get('AWS_SECRET_ACCESS_KEY')
AWS_REGION = 'us-east-1'  # Replace with your agent's region if different

# Initialize the Bedrock Agent Runtime client
bedrock_agent_runtime = boto3.client(
    service_name='bedrock-agent-runtime',
    region_name=AWS_REGION,
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY
)

def parse_xml_response(xml_string):
    # Remove all XML tags
    text_content = re.sub(r'<[^>]+>', '', xml_string)
    
    # Split the content into text and sources
    parts = text_content.split('Sources:')
    
    response_text = parts[0].strip()
    sources = []
    
    if len(parts) > 1:
        # Extract sources if present
        sources_text = parts[1].strip()
    
    return response_text, sources


def invoke_agent(agent_id, agent_alias_id, prompt):
    try:
        response = bedrock_agent_runtime.invoke_agent(
            agentId=agent_id,
            agentAliasId=agent_alias_id,
            sessionId='streamlit-session',
            inputText=prompt
        )
        
        completion = ""
        for event in response['completion']:
            if 'chunk' in event:
                chunk = event['chunk']
                completion += chunk['bytes'].decode('utf-8')
        
        text_response, sources = parse_xml_response(completion)
        return {"text_response": text_response, "sources": sources, "raw_response": completion}
    except ClientError as e:
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']
        st.error(f"AWS Error: {error_code} - {error_message}")
        return None
    except Exception as e:
        st.error(f"Error invoking agent: {str(e)}")
        return None








st.title("EA SporTS Valorant game Assistant")

# Input fields for Agent ID and Alias ID
agent_id = st.sidebar.text_input("Agent ID", value="I5FTKIP4O2")
agent_alias_id = st.sidebar.text_input("Agent Alias ID", value="RFNQNQSLWY")

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = []

# Display chat messages from history on app rerun
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        if message["role"] == "assistant":
            st.markdown(message["content"])
            st.markdown("**Sources:**")
            for source in message["sources"]:
                st.markdown(f"- {source}")
        else:
            st.markdown(message["content"])
    st.markdown("---")  # Add a separator between messages

# React to user input
if prompt := st.chat_input("What is your question?"):
    # Display user message in chat message container
    st.chat_message("user").markdown(prompt)
    # Add user message to chat history
    st.session_state.messages.append({"role": "user", "content": prompt})

    response = invoke_agent(agent_id, agent_alias_id, prompt)
    
    if response:
        # Display assistant response in chat message container
        with st.chat_message("assistant"):
            st.markdown(response['text_response'])
            if response['sources']:
                st.markdown("**Sources:**")
                for source in response['sources']:
                    st.markdown(f"- {source}")
        # Add assistant response to chat history
        st.session_state.messages.append({
            "role": "assistant", 
            "content": response['text_response'],
            "sources": response['sources']
        })
        
        # Display raw bot response
        with st.expander("Show Raw Bot Response"):
            st.text_area("", value=response['raw_response'], height=200)

# Add a button to clear the chat history
if st.button("Clear Chat History"):
    st.session_state.messages = []
    st.rerun()
