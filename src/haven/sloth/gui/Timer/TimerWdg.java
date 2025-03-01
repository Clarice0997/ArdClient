package haven.sloth.gui.Timer;


import haven.Audio;
import haven.Button;
import haven.Coord;
import haven.DefSettings;
import haven.FastText;
import haven.GOut;
import haven.Glob;
import haven.Label;
import haven.Resource;
import haven.UI;
import haven.Widget;
import haven.Window;
import haven.sloth.io.TimerData;
import haven.sloth.util.ObservableListener;

import java.util.Collection;

public class TimerWdg extends Widget implements ObservableListener<TimerData.TimerInstance> {
    private static final Resource timersfx = Resource.local().loadwait("custom/sfx/timer");
    private final static int width = UI.scale(420);
    private final static int height = UI.scale(31);
    private final static int txty = UI.scale(8);
    private final static Coord timec = new Coord(UI.scale(210), txty);

    private class TimerInstWdg extends Widget {
        final TimerData.TimerInstance inst;
        private long elapsed = time.duration;

        private TimerInstWdg(final TimerData.TimerInstance inst) {
            this.inst = inst;
            adda(new Button(UI.scale(50), "Cancel", this::cancel), new Coord(width - UI.scale(5), UI.scale(3)), 1, 0);
            pack();
        }

        @Override
        public void draw(GOut g) {
            FastText.aprint(g, timec, 0.5, 0, timeFormat(elapsed) + " (" + timeFormat((long) (elapsed / ui.sess.glob.getTimeFac())) + ")");
            super.draw(g);
        }

        @Override
        public void tick(double dt) {
            elapsed = time.duration / 3 - (long) ((ui.sess.glob.globtime() - inst.start));
            if (elapsed <= 0) {
                ui.gui.add(new TimerDoneWindow(time.name), new Coord(50, 50));
                Audio.play(timersfx, DefSettings.TIMERVOLUME.get() / 1000f);
                time.finish(inst);
            }
            super.tick(dt);
        }

        private void cancel() {
            time.finish(inst);
        }
    }

    public TimerData.Timer time;
    private Glob glob;
    private int base_height;

    public Button X, editbtn, startbtn;
    public Label namelbl, timelbl;

    TimerWdg(TimerData.Timer t, Glob glob) {
        time = t;
        this.glob = glob;
        sz = new Coord(width, height);
        namelbl = new Label(time.name);
        adda(namelbl, new Coord(UI.scale(3), sz.y / 2), 0, 0.5);
        X = new Button(UI.scale(20), "X", this::delete);
        adda(X, new Coord(sz.x - UI.scale(5), sz.y / 2), 1, 0.5);
        editbtn = new Button(UI.scale(50), "Edit", this::edit);
        adda(editbtn, new Coord(X.c.x - UI.scale(5), sz.y / 2), 1, 0.5);
        startbtn = new Button(UI.scale(50), "Start", this::start);
        adda(startbtn, new Coord(editbtn.c.x - UI.scale(5), sz.y / 2), 1, 0.5);
        timelbl = new Label(timeFormat(time.duration / 3) + " (" + timeFormat((long) (time.duration / 3 / getGlob().getTimeFac())) + ")");
        adda(timelbl, new Coord(startbtn.c.x - UI.scale(15), sz.y / 2), 1, 0.5);

        pack();
        base_height = sz.y;
    }

    private Glob getGlob() {
        return (glob);
    }

    @Override
    protected void added() {
        time.listen(this);
    }

    private static String timeFormat(long ts) {
        return String.format("%02d:%02d.%02d", (int) (ts / 3600), (int) ((ts % 3600) / 60), (int) (ts % 60));
    }

    public void start() {
        time.makeInstance((long) ui.sess.glob.globtime());
    }

    public void edit() {
        ui.gui.add(new TimerEditWnd("Edit Timer", time), new Coord(ui.gui.sz.x / 2 - UI.scale(200), ui.gui.sz.y / 2 - UI.scale(200)));
    }

    public void update() {
        namelbl.settext(time.name);
        timelbl.settext(timeFormat(time.duration / 3) + " (" + timeFormat((long) (time.duration / 3 / ui.sess.glob.getTimeFac())) + ")");
        timelbl.move(new Coord(startbtn.c.x - UI.scale(15), timelbl.c.y), 1, 0);
    }

    public void delete() {
        TimerData.remTimer(time);
    }

    @Override
    public void init(Collection<TimerData.TimerInstance> base) {
        for (final TimerData.TimerInstance inst : base) {
            add(new TimerInstWdg(inst));
        }
        pack();
        getparent(TimersWnd.class).pack();
    }

    @Override
    public void added(TimerData.TimerInstance item) {
        add(new TimerInstWdg(item));
        pack();
        getparent(TimersWnd.class).pack();
    }

    @Override
    public void edited(TimerData.TimerInstance olditem, TimerData.TimerInstance newitem) {
    }

    @Override
    public void remove(TimerData.TimerInstance item) {
        ui.destroy(find(item));
        pack();
        getparent(TimersWnd.class).pack();
    }

    public void pack() {
        int y = base_height;

        for (Widget wdg = child; wdg != null; wdg = wdg.next) {
            if (wdg instanceof TimerInstWdg) {
                wdg.c = new Coord(wdg.c.x, y);
                y += wdg.sz.y;
            }
        }
        super.pack();
    }

    public TimerInstWdg find(TimerData.TimerInstance t) {
        for (Widget wdg = child; wdg != null; wdg = wdg.next) {
            if (wdg instanceof TimerInstWdg) {
                TimerInstWdg tw = (TimerInstWdg) wdg;
                if (tw.inst == t)
                    return tw;
            }
        }

        return null;
    }

    @Override
    protected void removed() {
        time.unlisten(this);
    }

    private class TimerDoneWindow extends Window {
        private TimerDoneWindow(String timername) {
            super(UI.scale(300, 130), "Hooray!", "Hooray!");

            Label lbltimer = new Label(timername);
            add(lbltimer, new Coord(UI.scale(300) / 2 - lbltimer.sz.x / 2, UI.scale(20)));

            Label lblinf = new Label("has finished running");
            add(lblinf, new Coord(UI.scale(300) / 2 - lblinf.sz.x / 2, UI.scale(50)));

            adda(new Button(UI.scale(60), "Close") {
                @Override
                public void click() {
                    parent.reqdestroy();
                }
            }, new Coord(sz.x / 4, UI.scale(90)), 0.5, 0);
            adda(new Button(UI.scale(60), "Close & Restart") {
                @Override
                public void click() {
                    TimerWdg.this.start();
                    parent.reqdestroy();
                }
            }, new Coord(sz.x / 4 * 3, UI.scale(90)), 0.5, 0);
        }

        public void close() {
            ui.destroy(this);
        }
    }
}
