.PHONY: setup
setup:
	ansible-playbook -v -i inventory.ini main.yml
