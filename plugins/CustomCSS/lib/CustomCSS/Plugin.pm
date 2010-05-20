# Copyright (C) 2009 Byrne Reese

package CustomCSS::Plugin;

use strict;

use Carp qw( croak );
use MT::Util qw( relative_date offset_time offset_time_list epoch2ts ts2epoch format_ts );

sub plugin {
    return MT->component('CustomCSS');
}

sub id { 'custom_css' }

sub uses_custom_css {
#    local $@;
    my $blog = MT->instance->blog;

    return 0 if !$blog;

    # If the user has forcibly enabled custom css, then return true.
    return 1 if plugin()->get_config_value('force_enable_custom_css','blog:'.$blog->id);
 
    # If the user is utilizing a template set for which custom css has been enabled
    # for an index template, return true.
    my $ts = MT->instance->blog->template_set;
    my $app = MT::App->instance;
    return 0 if (ref($app->registry('template_sets',$ts,'templates')) ne 'HASH');
    my $tmpls = $app->registry('template_sets',$ts,'templates','index');
    foreach my $t (keys %$tmpls) {
	return 1 if $tmpls->{$t}->{custom_css};
    }
    return 0;
}

sub edit {
    my $app = shift;
    my ($param) = @_;
    my $q = $app->{query};

    $param ||= {};

    # to trigger autosave logic in main edit routine
    $param->{autosave_support} = 1;

    my $blog = $app->blog;
    my $cfg = $app->config;
    my $perms = $app->permissions;
    my $can_preview = 0;

    $param->{search_label} = $app->translate('Templates');
    $param->{object_type}  = 'template';
    $param->{saved} = 1 if $q->param('saved');
    $param->{saved_rebuild} = 1 if $q->param('saved_rebuild');

    # Populate structure for template snippets
    if ( my $snippets = $app->registry('template_snippets') || {} ) {
        my @snippets;
        for my $snip_id ( keys %$snippets ) {
            my $label = $snippets->{$snip_id}{label};
            $label = $label->() if ref($label) eq 'CODE';
            push @snippets,
              {
                id      => $snip_id,
                trigger => $snippets->{$snip_id}{trigger},
                label   => $label,
                content => $snippets->{$snip_id}{content},
              };
        }
        @snippets = sort { $a->{label} cmp $b->{label} } @snippets;
        $param->{template_snippets} = \@snippets;
    }

    $param->{screen_id} = "edit-template-" . $param->{type};

    # if unset, default to 30 so if they choose to enable caching,
    # it will be preset to something sane.
    $param->{cache_expire_interval} ||= 30;

    $param->{dirty} = 1
        if $app->param('dirty');

    my $plugin = plugin();
    my $scope = "blog:" . $blog->id;
    $param->{'text'} = $plugin->get_config_value('custom_css',$scope);


    $param->{template_lang} = 'css';
    return $app->load_tmpl( 'custom_css.tmpl', $param );
}

sub save {
    my $app = shift;
    my $q = $app->{query};
    my $blog = MT::Blog->load($q->param('blog_id'));

    my $css = $q->param('text');

    my $plugin = plugin();
    my $scope = "blog:" . $blog->id;
    $plugin->set_config_value('custom_css',$css,$scope);

    my $ts = MT->instance->blog->template_set;
    my $tmpls = $app->registry('template_sets',$ts,'templates','index');
    foreach my $t (keys %$tmpls) {
    if ($tmpls->{$t}->{custom_css}) {
        my $tmpl = MT->model('template')->load({
        blog_id => $blog->id,
        identifier => $t,
            });
        MT->log({ 
        blog_id => $blog->id,
        message => 'Custom CSS plugn is republishing ' . $tmpl->name,
        });
        $app->rebuild_indexes(
        Blog     => $blog,
        Template => $tmpl,
        Force    => 1,
        );
    }
    }

    $app->add_return_arg( saved => 1 );
    return $app->call_return;
}

sub custom_css {
    my ($ctx, $args) = @_;
    my $blog = $ctx->stash('blog');
    my $plugin = plugin();
    my $scope = "blog:" . $blog->id;
    return $plugin->get_config_value('custom_css',$scope);
}

1;
__END__
