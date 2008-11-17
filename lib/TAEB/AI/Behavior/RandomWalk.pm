#!/usr/bin/env perl
package TAEB::AI::Behavior::RandomWalk;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my @possibilities;
    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;
        push @possibilities, $dir if $tile->is_walkable;
    });

    return URG_NONE if !@possibilities;

    $self->do(move => direction => $possibilities[rand @possibilities]);
    return URG_FALLBACK;
}

sub currently { "Randomly walking" }

sub urgencies {
    return {
        URG_FALLBACK, "random walk!",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

