#!/usr/bin/env perl
package TAEB::Action::Throw;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

use constant command => 't';

has item => (
    isa      => 'TAEB::World::Item',
    required => 1,
);

sub respond_throw_what { shift->item->slot }

# we don't get a message when we throw one dagger
sub done { TAEB->inventory->decrease_quantity(shift->item->slot) }

sub msg_throw_count {
    my $self  = shift;
    my $count = shift;

    # done takes care of the other one
    TAEB->inventory->decrease_quantity(shift->item->slot, $count - 1);
}

make_immutable;
no Moose;

1;

