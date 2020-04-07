from ranger.api.commands import Command
import os.path
import subprocess

class fzf(Command):
    """
    :fzf

    Find a file or directory using fzf
    """
    def execute(self):
        command = "find ${HOME} -path ${HOME}/Library -prune -o -print | fzf --height 10"
        fzf = self.fm.execute_command(command, stdout=subprocess.PIPE)
        stdout, stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_path = os.path.abspath(stdout.decode('utf-8').rstrip('\n'))
            if os.path.isdir(fzf_path):
                self.fm.cd(fzf_path)
            else:
                self.fm.select_file(fzf_path)
