package LimitBreaker::Plugin;
use strict;
use warnings;

sub _cb_init_app {
    my ( $cb, $app ) = @_;
    if ( ref( $app ) eq 'MT::App::CMS' ) {
        my $_init_request = *MT::App::init_request{CODE};
        *MT::App::init_request = sub {
            my $app = shift;
            MT->run_callbacks( ref( $app ) . '::pre_init_request', $app, @_ );
            my $ret = $_init_request->( $app, @_ );
            MT->run_callbacks( ref( $app ) . '::post_init_request', $app, @_ );
            return $ret;
        };
    }
    1;
}

sub _cb_pre_init_request {
    my ( $cb, $app ) = @_;
    if ( $app->request_method eq 'POST' ) {
        MT->config( '_CGIMaxUpload', MT->config->CGIMaxUpload );
        MT->config( 'CGIMaxUpload', 1024 ** 4 );
    }
    1;
}

sub _cb_init_request {
    my $cb = shift;
    my $app = shift;
    my $q = $app->param();

    if ( $app->request_method ne 'POST' ) {
        return 1;
    }

    my %params = map {$_ => $q->param($_)} $q->all_parameters;
    unless ( $q->param( 'ignore_max_upload' ) ) {
        if ( my $cgi_max_upload = MT->config->_CGIMaxUpload ) {
            MT->config( 'CGIMaxUpload', $cgi_max_upload );
            MT->config( '_CGIMaxUpload', undef );
            # check
            if ( my $content_length = $ENV{'CONTENT_LENGTH'} ) {
                if ( $content_length > $cgi_max_upload ) {
                    $q->cgi_error("413 Request entity too large");
                }
            }
        }
    }
    1;
}

sub _cb_post_run {
    my ( $cb, $app ) = @_;
    if ( my $cgi_max_upload = MT->config->_CGIMaxUpload ) {
        MT->config( 'CGIMaxUpload', $cgi_max_upload );
        MT->config( '_CGIMaxUpload', undef );
    }
    1;
}

sub _cb_tp_asset_upload {
    my ( $cb, $app, $param, $tmpl ) = @_;
    my $plugin = MT->component( 'LimitBreaker' );

    if ( my $blog = $app->blog ) {
        if ( my $pointer_node = $tmpl->getElementById( 'site_path' ) ) {
            my $nodeset = $tmpl->createElement(
                'app:setting',
                {   id    => 'ignore_max_upload',
                    label => '',
                    label_class => 'top-level',
                }
            );
            my $inner_html
                = '<label><input type="checkbox" name="ignore_max_upload" id="ignore_max_upload" /> ' .
                $plugin->translate( 'Ignore CGIMaxUpload' ) .
                '</label>';
            $nodeset->innerHTML( $inner_html );
            $tmpl->insertAfter( $nodeset, $pointer_node );
        }
    }
}


1;
