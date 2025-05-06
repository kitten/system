[GtkTemplate(ui="/ui/Bar.ui")]
class Bar : Astal.Window {
    public string volume_icon { get; set; }
    public string battery_visible { get; set; }
    public string battery_label { get; set; }
    public string battery_icon { get; set; }
    public string network_icon { get; set; }

    public Bar() {
        namespace = "hyprpanel";
        anchor = TOP | LEFT | RIGHT;
        exclusivity = EXCLUSIVE;
        add_css_class("Bar");
        present();

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
    }

    public override void dispose() {
        base.dispose();
    }
}

