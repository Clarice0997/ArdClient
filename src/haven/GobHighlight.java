package haven;

import java.awt.Color;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;

public class GobHighlight extends GAttrib {
    private float[] emi = {1.0f, 0.0f, 1.0f, 0.0f};
    private float[] clr = Utils.c2fa(new Color(255, 0, 255, 0));
    private boolean inc = true;
    private static final float EMI_STEP = 0.0625f;
    private static final float ALPHA_STEP = 0.0627450980484f;
    private long lasttime = System.currentTimeMillis();
    public long cycle = 6;

    public GobHighlight(Gob g) {
        super(g);
    }

    private static final Map<Long, Material.Colors> stateMap = Collections.synchronizedMap(new HashMap<>());
    private final AtomicLong atomicLong = new AtomicLong();
    public GLState getfx() {
        if (cycle <= 0)
            return GLState.nullstate;

        long now = System.currentTimeMillis();
        if (now - lasttime > 5) {
            lasttime = now;
            if (inc) {
                emi[3] += EMI_STEP;
                if ((clr[3] += ALPHA_STEP) > 1.0f) {
                    emi[3] = clr[3] = 1.0f;
                    cycle--;
                    inc = false;
                }
            } else {
                emi[3] -= EMI_STEP;
                if ((clr[3] -= ALPHA_STEP) < 0.0f) {
                    emi[3] = clr[3] = 0;
                    cycle--;
                    inc = true;
                }
            }
            atomicLong.incrementAndGet();
        }

        return (stateMap.computeIfAbsent(atomicLong.get(), t -> (new Material.Colors(clr, clr, clr, emi, 128))));
    }

    public Object staticp() {
        return null;
    }
}
