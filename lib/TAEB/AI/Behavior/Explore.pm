#!/usr/bin/env perl
package TAEB::AI::Behavior::Explore;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my $path = TAEB::World::Path->first_match(
        sub {
            my $tile = shift;
            !$tile->explored && $tile->is_walkable
        },
    );

    $self->path($path);

    return $path && length($path->path) ? 100 : 0;
}

sub next_action {
    my $self = shift;
    substr($self->path->path, 0, 1);
}

sub currently { "Exploring." }

1;

