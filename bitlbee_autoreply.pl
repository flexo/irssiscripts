# Sends autoreplies to IM users when they message while you are away.
#
# SETTINGS
# [bitlbee]
# bitlbee_autoreply_duration = OFF
#   -> Send how long you have been away in your auto-reply. This requires
#      Time::Duration.
#      Example auto-reply: "gone (away: 3 minutes and 2 seconds)"
use strict;
use Irssi;
use Time::Duration qw/duration_exact/; # apt-get install libtime-duration-perl

use vars qw($VERSION %IRSSI);

$VERSION = '0.12';
%IRSSI = (
  authors     => 'Matt "f0rked" Sparks, Nick Murdoch',
  contact     => 'ms+irssi@quadpoint.org',
  name        => 'bitlbee status notice',
  description => 'Sends autoreplies to IM users while you are away',
  license     => 'GPLv2',
  url         => 'http://quadpoint.org',
  changed     => '2012-04-22',
);

my $bitlbee_channel = "&bitlbee";
my $bitlbee_server_tag = "femputer";

my(%times, $away, $away_time);


sub away
{
  $away_time=time;
  %times=();
}


sub event_msg
{
  my($server, $msg, $nick, $address, $target) = @_;
  return if $server->{tag} ne $bitlbee_server_tag;
  return unless $server->{usermode_away};
  return unless $address =~ /\@chat.facebook.com$/;  # Only send for AIM.
  return unless !$target or ($target eq $bitlbee_channel and $nick ne "root");
  return unless time - $times{$nick} > 3600;  # send an auto-reply once an hour.

  $times{$nick} = time;
  my $append;
  if (Irssi::settings_get_bool("bitlbee_autoreply_duration") && $away_time) {
    $append = " (away: " . duration_exact(time - $away_time) . ")";
  }

  my $preamble = Irssi::settings_get_str("bitlbee_autoreply_preamble");

  $server->command("/notice $nick $preamble$server->{away_reason}$append");
}


Irssi::signal_add("message private", "event_msg");
Irssi::signal_add("message public", "event_msg");
Irssi::signal_add("away mode changed", "away");

Irssi::settings_add_str("bitlbee", "bitlbee_autoreply_preamble", "(Autoreply) I am not here right now: ");
Irssi::settings_add_bool("bitlbee", "bitlbee_autoreply_duration", 0);
