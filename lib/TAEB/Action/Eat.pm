#!/usr/bin/env perl
package TAEB::Action::Eat;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Item';
use List::MoreUtils 'any';

use constant command => "e";

has '+item' => (
    required => 1,
);

sub respond_eat_ground {
    my $self = shift;
    my $item = TAEB->new_item(shift);

    # no, we want to eat something in our inventory
    return 'n' if blessed $self->item;

    if ($self->item eq 'any') {
        if (TAEB::Spoilers::Item::Food->should_eat($item)) {
            TAEB->debug("Floor-food $item is good enough for me.");
            # keep track of what we're eating for nutrition purposes later
            $self->item($item);
            return 'y';
        }
        else {
            TAEB->debug("Floor-food $item is on the blacklist. Pass.");
        }
    }

    # we're specific about this. really
    return 'y' if $item->identity eq $self->item;

    # no thanks, I brought my own lunch
    return 'n';
}

sub respond_eat_what {
    my $self = shift;
    return $self->item->slot if blessed($self->item);

    if ($self->item eq 'any') {
        my $item = TAEB->find_item(sub { $self->can_eat(@_) });

        if ($item) {
            $self->item($item);
            return $item->slot;
        }
        TAEB->error("There's no safe food in my inventory, so I can't eat 'any'. Sending escape, but I doubt this will work.");
    }
    else {
        TAEB->error("Unable to eat '" . $self->item . "'. Sending escape, but I doubt this will work.");
    }

    $self->aborted(1);
    return "\e\e\e";
}

sub post_responses {
    my $self = shift;
    my $item = $self->item;

    # we had no match for "any", so we have nothing to do
    return unless blessed $item;

    if ($item->slot) {
        TAEB->inventory->decrease_quantity($item->slot)
    }
    else {
        TAEB->enqueue_message('remove_floor_item' => $item);
    }

    my $old_nutrition = TAEB->senses->nutrition;
    my $new_nutrition = $old_nutrition + $item->nutrition;

    TAEB->debug("Eating $item is increasing our nutrition from $old_nutrition to $new_nutrition");
    TAEB->senses->nutrition($new_nutrition);
}

# is there any food around?
sub any_food {
    my $self = shift;

    return any { $self->can_eat($_) }
           TAEB->current_tile->items,
           TAEB->inventory->items;
}

sub can_eat {
    my $self = shift;
    my $item = shift;

    return 0 unless $item->class eq 'food';
    return 0 unless TAEB::Spoilers::Item::Food->should_eat($item);
    return 0 if $item->identity eq 'lizard corpse'
             && TAEB->nutrition > 5;
    return 1;
}

before exception_missing_item => sub {
    my $self = shift;
    if ($self->item eq 'any') {
        TAEB->enqueue_message(check => 'inventory');
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

