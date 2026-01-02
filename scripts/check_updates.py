#!/usr/bin/env python3
import sys
import subprocess
import hashlib
import json
import os

def run_cmd(cmd):
    return subprocess.check_output(cmd, shell=True).decode('utf-8').strip()

def get_base_digest():
    print("Fetching node:24-alpine digest...")
    # Pull minimal info or just pull the image (caching makes this fast)
    run_cmd("docker pull node:24-alpine")
    digest = run_cmd("docker inspect --format='{{.RepoDigests}}' node:24-alpine")
    # Format is typically [node@sha256:..., ...]
    # We strip 'node@' and brackets
    if "[" in digest:
        digest = digest.strip("[]").split(" ")[0]
    return digest

def get_hb_version():
    print("Fetching latest homebridge version from NPM...")
    # Use npm view. We don't have npm in this python env? 
    # Actions usually have npm.
    # If not, we can use curl to registry.
    try:
        ver = run_cmd("npm view homebridge version")
        return ver
    except:
        # Fallback to curl if npm not found
        import urllib.request
        resp = urllib.request.urlopen("https://registry.npmjs.org/homebridge/latest")
        data = json.loads(resp.read())
        return data["version"]

def check_git_tag(tag):
    print(f"Checking if tag '{tag}' exists...")
    try:
        # Fetch tags first
        run_cmd("git fetch --tags")
        run_cmd(f"git rev-parse {tag}")
        return True
    except subprocess.CalledProcessError:
        return False

def main():
    try:
        base_digest = get_base_digest()
        hb_version = get_hb_version()
        
        print(f"Base Digest: {base_digest}")
        print(f"Homebridge Version: {hb_version}")
        
        # Create a unique signature hash
        sig_raw = f"{base_digest}-{hb_version}"
        sig_hash = hashlib.md5(sig_raw.encode()).hexdigest()[:12]
        
        sig_tag = f"build-{sig_hash}"
        
        if check_git_tag(sig_tag):
            print(f"Signature tag {sig_tag} already exists. Nothing new.")
            # Set Github Output
            with open(os.environ['GITHUB_OUTPUT'], 'a') as fh:
                fh.write("should_build=false\n")
        else:
            print(f"New configuration detected! ({sig_tag})")
            with open(os.environ['GITHUB_OUTPUT'], 'a') as fh:
                fh.write("should_build=true\n")
                fh.write(f"sig_tag={sig_tag}\n")
                fh.write(f"hb_version={hb_version}\n")
                
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
