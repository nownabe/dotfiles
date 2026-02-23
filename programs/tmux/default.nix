{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-x";
    terminal = "tmux-256color";
    keyMode = "vi";
    mouse = true;
    escapeTime = 0;
    baseIndex = 1;
    historyLimit = 50000;
    clock24 = true;
    sensibleOnTop = true;
    focusEvents = true;

    plugins = [
      {
        plugin = pkgs.tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_session_color "#{?client_prefix,#{@thm_peach},#{@thm_lavender}}"
        '';
      }
    ];

    extraConfig = ''
      # Terminal features
      set -as terminal-features ",xterm-256color:RGB"
      set -g set-clipboard on
      set -g renumber-windows on
      setw -g automatic-rename on

      # Status bar
      set -g status-left "#{E:@catppuccin_status_session}"
      set -g status-right "#{E:@catppuccin_status_host}#{E:@catppuccin_status_date_time}"

      # Inactive pane visual distinction
      set -g window-style "fg=colour247,bg=default"
      set -g window-active-style "fg=colour250,bg=default"

      # Pane splitting
      bind '\' split-window -v -c "#{pane_current_path}"
      bind '|' split-window -h -c "#{pane_current_path}"

      # Pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize mode
      bind R switch-client -T resize_pane
      bind -T resize_pane h resize-pane -L 1 \; switch-client -T resize_pane
      bind -T resize_pane j resize-pane -D 1 \; switch-client -T resize_pane
      bind -T resize_pane k resize-pane -U 1 \; switch-client -T resize_pane
      bind -T resize_pane l resize-pane -R 1 \; switch-client -T resize_pane
      bind -T resize_pane Escape switch-client -T prefix

      # Window navigation (prefix-free)
      bind -n M-h previous-window
      bind -n M-l next-window

      # New window
      bind n new-window -c "#{pane_current_path}"

      # Session navigation (prefix-free)
      bind -n M-j switch-client -n
      bind -n M-k switch-client -p

      # Session management
      bind s choose-tree -sZ
      bind S command-prompt "new-session -s '%%'"
      bind r command-prompt -I "#S" "rename-session -- '%%'"

      # Copy mode
      bind Space copy-mode
      bind v paste-buffer

      # Copy mode vi bindings
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi V send-keys -X select-line
      bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind -T copy-mode-vi q send-keys -X cancel
      bind -T copy-mode-vi Escape send-keys -X cancel

      # Passthrough Ctrl+X to shell
      bind x send-keys C-x
    '';
  };
}
