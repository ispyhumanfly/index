#!/usr/bin/perl

use 5.010_000;
use strict;
use warnings;

BEGIN {

    mkdir '/tmp/.altair/object-storage/'
      unless -e '/tmp/.altair/object-storage/';
}

use Mojolicious::Lite;
use Mojo::Util;
use Mojo::JSON;
use Mojo::Log;
use File::Slurp;
use File::Copy;
use IO::Dir;
use IO::File;

plugin 'JSONConfig' => {file => 'server.config'};

my $OBJECTS = app->config->{storage};
my $LOG     = Mojo::Log->new;


### O B J E C T

get '/:object' => [object => qr/\w+/] => sub {

    my $self = shift;

    my $object = $self->param('object');

    return $self->render(json => get_object("$OBJECTS/$object"));
};

post '/:object' => [object => qr/\w+/] => sub {

    my $self   = shift;
    my $object = $self->param('object');
};

get '/:folder_1/:object' => [
    folder_1 => qr/\w+/,
    object   => qr/\w+/
  ] => sub {

    my $self = shift;

    my $folder_1 = $self->param('folder_1');
    my $object   = $self->param('object');

    return $self->render(json => get_object("$OBJECTS/$folder_1/$object"));
  };

post '/:folder_1/:object' => [
    folder_1 => qr/\w+/,
    object   => qr/\w+/
  ] => sub {

    my $self = shift;
  };

get '/:folder_1/:folder_2/:object' => [
    folder_1 => qr/\w+/,
    folder_2 => qr/\w+/,
    object   => qr/\w+/
  ] => sub {

    my $self = shift;

    my $folder_1 = $self->param('folder_1');
    my $folder_2 = $self->param('folder_2');
    my $object   = $self->param('object');

    return $self->render(
        json => get_object("$OBJECTS/$folder_1/$folder_2/$object"));
  };

post '/:folder_1/:folder_2/:object' => [
    folder_1 => qr/\w+/,
    folder_2 => qr/\w+/,
    object   => qr/\w+/
  ] => sub {

    my $self = shift;
  };

get '/:folder_1/:folder_2/:folder_3/:object' => [
    folder_1 => qr/\w+/,
    folder_2 => qr/\w+/,
    folder_3 => qr/\w+/,
    object   => qr/\w+/
  ] => sub {

    my $self = shift;

    my $folder_1 = $self->param('folder_1');
    my $folder_2 = $self->param('folder_2');
    my $folder_3 = $self->param('folder_3');
    my $object   = $self->param('object');

    return $self->render(
        json => get_object("$OBJECTS/$folder_1/$folder_2/$folder_3/$object"));
  };

post '/:folder_1/:folder_2/:folder_3/:object' => [
    folder_1 => qr/\w+/,
    folder_2 => qr/\w+/,
    folder_3 => qr/\w+/,
    object   => qr/\w+/
  ] => sub {

    my $self = shift;
  };

sub get_object {

    my $object = shift;

    if (-e $object) {

        $object = Mojo::JSON::decode_json(File::Slurp::read_file($object));
    }

    return $object;
}


### O B J E C T S

get '/objects.json' => sub {

    my $self = shift;
    return $self->render(json => get_objects($OBJECTS));
};

get '/:folder_1/objects.json' => [folder_1 => qr/\w+/] => sub {

    my $self = shift;

    my $folder_1 = $self->param('folder_1');
    return $self->render(json => get_objects("$OBJECTS/$folder_1/"));
};

get '/:folder_1/:folder_2/objects.json' =>
  [folder_1 => qr/\w+/, folder_2 => qr/\w+/] => sub {

    my $self = shift;

    my $folder_1 = $self->param('folder_1');
    my $folder_2 = $self->param('folder_2');
    return $self->render(
        json => get_objects("$OBJECTS/$folder_1/$folder_2/"));
  };

get '/:folder_1/:folder_2/:folder_3/objects.json' =>
  [folder_1 => qr/\w+/, folder_2 => qr/\w+/, folder_3 => qr/\w+/] => sub {

    my $self = shift;

    my $folder_1 = $self->param('folder_1');
    my $folder_2 = $self->param('folder_2');
    my $folder_3 = $self->param('folder_3');

    return $self->render(
        json => get_objects("$OBJECTS/$folder_1/$folder_2/$folder_3/"));
  };

sub get_objects {

    mkdir shift unless -e shift;

    my $directory = IO::Dir->new(shift);

    my @objects;

    if (defined $directory) {

        while (defined($_ = $directory->read)) {

            push @objects, {name => $_};
        }

        undef $directory;
    }

    return \@objects;
}

app->start();