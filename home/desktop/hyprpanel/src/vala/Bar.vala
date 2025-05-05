[GtkTemplate(ui="/ui/Bar.ui")]
class Bar : Astal.Window {
    public string clock { get; set; }
    public string volume_icon { get; set; }
    public string battery_visible { get; set; }
    public string battery_label { get; set; }
    public string battery_icon { get; set; }
    public double volume { get; set; }
    public string network_icon { get; set; }
    public bool mpris_visible { get; set; }
    public string mpris_label { get; set; }
    public string mpris_art { get; set; }
    public string power_profile_icon { get; set; }
    public bool bluetooth_visible { get; set; }

    AstalIO.Time timer;
    AstalMpris.Player player;

    [GtkChild] unowned Gtk.Popover popover;
    [GtkChild] unowned Gtk.Calendar calendar;

    public Bar() {
        anchor = TOP | LEFT | RIGHT;
        exclusivity = EXCLUSIVE;
        add_css_class("Bar");
        present();

        // clock
        timer = AstalIO.Time.interval(1000, null);
        timer.now.connect(() => {
            clock = new DateTime.now_local().format("%H:%M:%S");
        });

        // everytime popover is opened, select current day
        popover.notify["visible"].connect(() => {
            if (popover.visible) {
                calendar.select_day(new DateTime.now_local());
            }
        });

        // network
        var nw = AstalNetwork.get_default();
        Binding networkBinding = null;

        nw.bind_property(
            "primary",
            this,
            "network-icon",
            BindingFlags.SYNC_CREATE,
            (_, primary) => {
                if (networkBinding != null) networkBinding.unbind();

                switch (primary.get_enum()) {
                    case AstalNetwork.Primary.WIRED:
                        networkBinding = nw.wired.bind_property(
                            "icon-name",
                            this,
                            "network-icon",
                            BindingFlags.SYNC_CREATE
                        );
                        return false;

                    case AstalNetwork.Primary.WIFI:
                        networkBinding = nw.wifi.bind_property(
                            "icon-name",
                            this,
                            "network-icon",
                            BindingFlags.SYNC_CREATE
                        );
                        return false;

                    default:
                        network_icon = "network-idle-symbolic";
                        return false;
                }
            },
            null
        );

        // battery
        var bat = AstalBattery.get_default();
        bat.bind_property("is-present", this, "battery-visible", BindingFlags.SYNC_CREATE);
        bat.bind_property("icon-name", this, "battery-icon", BindingFlags.SYNC_CREATE);
        bat.bind_property("percentage", this, "battery-label", BindingFlags.SYNC_CREATE, (_, src, ref target) => {
            target.set_string(@"$(Math.floor(bat.percentage * 100))%");
            return true;
        }, null);

        // volume
        var speaker = AstalWp.get_default().get_default_speaker();
        speaker.bind_property("volume-icon", this, "volume-icon", BindingFlags.SYNC_CREATE);
        speaker.bind_property("volume", this, "volume", BindingFlags.SYNC_CREATE);

        // mpris
        player = new AstalMpris.Player("spotify");
        player.bind_property("available", this, "mpris-visible", BindingFlags.SYNC_CREATE);
        player.bind_property("cover-art", this, "mpris-art", BindingFlags.SYNC_CREATE);
        player.bind_property("metadata", this, "mpris-label", BindingFlags.SYNC_CREATE, (_, src, ref target) => {
            if (player.title == null || player.artist == null) {
                return false;
            }
            target.set_string(@"$(player.artist) - $(player.title)");
            return true;
        }, null);

        // powerprofiles
        var powerprofile = AstalPowerProfiles.get_default();
        powerprofile.bind_property("icon-name", this, "power-profile-icon", BindingFlags.SYNC_CREATE);

        // bluetooth
        var bt = AstalBluetooth.get_default();
        bt.bind_property("is-connected", this, "bluetooth-visible", BindingFlags.SYNC_CREATE);
    }

    [GtkCallback]
    bool change_volume(Gtk.Range scale, Gtk.ScrollType type, double value) {
        AstalWp.get_default().get_default_speaker().set_volume(value);
        return true;
    }

    public override void dispose() {
        timer.cancel();
        timer.dispose();
        player.dispose();
        base.dispose();
    }
}

