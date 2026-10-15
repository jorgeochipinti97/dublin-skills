// Episode theme for Tribuna (@tribuna.ar): black-and-white identity, Bebas Neue, and the cast.
// Cast = paper football people (not the kit critter): Boca players are paper bodies in the Boca shirt with their real face as a
// magazine cutout (public/cast/<name>-head.png, cut from the article photo); the doctor and the coach are drawn, no real faces.
// Sets = football places drawn in paper: Vestuario (locker room / medical room), Cancha (pitch + stands), Pizarra (tactics board).
import React from 'react';
import {Img, continueRender, delayRender, staticFile, useCurrentFrame} from 'remotion';
import {C, FONT} from './lib/tokens';
import {Disc, Paper, Slab, bob} from './lib/paper/kit';

// ---------- identity: Tribuna is black and white; the hot word is inverted (white tag, black text) ----------
Object.assign(C, {
  tag: '#0A0A0A', tagText: '#FFFFFF', sparkYellow: '#FFFFFF', cream: '#F4F2EE', creamHi: '#FFFFFF', creamLo: '#D9D6CF', tape: '#D8D4CA', ink: '#0A0A0A',
});
Object.assign(FONT, {banner: 'Bebas Neue', caption: 'Bebas Neue'});
const fontHandle = delayRender('Bebas Neue');
Promise.all([
  new FontFace('Bebas Neue', `url(${staticFile('fonts/bebas-neue-400-latin.woff2')}) format('woff2')`, {weight: '100 900'}).load(),
  new FontFace('Bebas Neue', `url(${staticFile('fonts/bebas-neue-400-latin-ext.woff2')}) format('woff2')`, {weight: '100 900', unicodeRange: 'U+0100-024F, U+1E00-1EFF'}).load(),
]).then((faces) => { faces.forEach((x) => document.fonts.add(x)); continueRender(fontHandle); });

export const TH = {
  boca: '#1F3F8C', bocaLo: '#142B63', oro: '#F2BE2C', oroLo: '#C99712',
  skin: '#D9A07A', skinLo: '#B97F5B', hair: '#2A211C',
  coat: '#F4F3EF', coatLo: '#CFCCC4', suit: '#1B1B1D', suitLo: '#0B0B0C', suitHi: '#34343A',
  vasco: '#F2F0EA', vascoLo: '#C9C5BA', red: '#D2282E',
  grass: '#3E8E4A', grassLo: '#327A3D', grassHi: '#4C9F57', line: '#F3F1EA',
  ink: '#0A0A0A', white: '#FFFFFF', paper: '#F4F2EE',
};

// Tribuna wordmark (black PNG). `invert` makes it white for dark sets.
export const TribunaLogo: React.FC<{x: number; y: number; w?: number; invert?: boolean; opacity?: number}> = ({x, y, w = 260, invert, opacity = 1}) => (
  <Img src={staticFile('cast/tribuna-logo.png')} style={{position: 'absolute', left: x, top: y, width: w, opacity, filter: invert ? 'invert(1)' : undefined}} />
);

// ---------- the paper person ----------
export type Face = 'idle' | 'shock' | 'worried' | 'happy' | 'angry';
type Kit = {shirt: string; shirtLo: string; band?: string; bandLo?: string; shorts: string; shortsLo: string; socks: string; shoes: string; coat?: boolean; cap?: boolean; pants?: string; pantsLo?: string};
export type PersonProps = {
  x: number; y: number;            // (x, y) = the ground point between the feet
  h?: number;                      // full height in px (head included), default 520
  face?: 1 | -1;                   // 1 = facing right
  lean?: number;                   // whole-body tilt, deg
  armL?: number; armR?: number;    // arm angle in deg from hanging: 0 down, 90 straight out sideways, 160 up
  legL?: number; legR?: number;    // leg swing in deg (positive = forward)
  run?: number;                    // >0: running cycle speed (frames per stride); overrides legs/arms
  lift?: number; phase?: number; idle?: boolean;
  expr?: Face;
  hold?: React.ReactNode;          // drawn at the right hand
  tag?: string;                    // name pill over the head
  tagTop?: number;                 // name pill height above the shoulders, in % of h (default 36)
};

const Head: React.FC<{u: number; expr: Face; hair: string; cap?: boolean; f: number}> = ({u, expr, hair, cap, f}) => {
  const w = 22 * u, hh = 25 * u;
  const blink = expr === 'idle' && f % 79 < 3;
  const eyeH = expr === 'shock' ? 3.4 * u : blink ? 0.5 * u : 2.4 * u;
  return (
    <Paper lift={4}><div style={{position: 'absolute', left: -w / 2, top: -hh, width: w, height: hh}}>
      {/* ears */}
      <Slab x={-1.6 * u} y={10 * u} w={3.2 * u} h={5 * u} color={TH.skinLo} r="50%" />
      <Slab x={w - 1.6 * u} y={10 * u} w={3.2 * u} h={5 * u} color={TH.skinLo} r="50%" />
      <Slab x={0} y={0} w={w} h={hh} color={TH.skin} shade={TH.skinLo} shadeH={0.14} r="42% 42% 46% 46%" />
      {/* hair */}
      <Slab x={-0.6 * u} y={-1.6 * u} w={w + 1.2 * u} h={8.4 * u} color={hair} r="50% 50% 18% 18%" />
      {cap ? (
        <>
          <Slab x={-1 * u} y={-3.4 * u} w={w + 2 * u} h={8.6 * u} color={TH.suit} shade={TH.suitLo} shadeH={0.3} r="55% 55% 10% 10%" />
          <Slab x={w * 0.45} y={3.8 * u} w={w * 0.75} h={1.8 * u} color={TH.suitLo} r={4} />
        </>
      ) : null}
      {/* brows (angry / worried tilt) */}
      {[0, 1].map((i) => (
        <div key={`b${i}`} style={{position: 'absolute', left: (i ? 13.2 : 4.6) * u, top: 8.6 * u - (expr === 'shock' ? 1.4 * u : 0), width: 4.2 * u, height: 0.9 * u, background: TH.hair, borderRadius: 2,
          rotate: `${(expr === 'angry' ? 14 : expr === 'worried' ? -14 : 0) * (i ? -1 : 1)}deg`}} />
      ))}
      {/* eyes */}
      {[0, 1].map((i) => (
        <div key={`e${i}`} style={{position: 'absolute', left: (i ? 14.4 : 5.8) * u, top: 11 * u, width: 1.9 * u, height: eyeH, background: TH.ink, borderRadius: 3}} />
      ))}
      {/* nose */}
      <Slab x={10.2 * u} y={14 * u} w={1.8 * u} h={3.4 * u} color={TH.skinLo} r={4} />
      {/* mouth */}
      {expr === 'shock' ? <div style={{position: 'absolute', left: 9.3 * u, top: 18.6 * u, width: 3.6 * u, height: 3.6 * u, borderRadius: '50%', background: '#3A1512'}} />
        : expr === 'happy' ? <div style={{position: 'absolute', left: 7.6 * u, top: 18.4 * u, width: 7 * u, height: 3 * u, borderRadius: '0 0 4em 4em', background: '#3A1512'}} />
        : <div style={{position: 'absolute', left: 8.4 * u, top: 19.6 * u, width: 5.4 * u, height: 0.9 * u, borderRadius: 3, background: '#3A1512', rotate: expr === 'worried' || expr === 'angry' ? '-6deg' : '0deg'}} />}
    </div></Paper>
  );
};

const Person: React.FC<PersonProps & {kit: Kit; head: (u: number, f: number) => React.ReactNode}> = ({
  x, y, h = 520, face = 1, lean = 0, armL = 8, armR = 8, legL = 0, legR = 0, run = 0, lift = 0, phase = 0, idle = true, hold, tag, tagTop = 36, kit, head,
}) => {
  const f = useCurrentFrame();
  const u = h / 100;
  const b = idle && !run ? bob(f, 40, 2.5, phase) : 0;
  let lL = legL, lR = legR, aL = armL, aR = armR, runLift = 0;
  if (run > 0) {
    const s = Math.sin(((f + phase) / run) * Math.PI * 2);
    lL = 30 * s; lR = -30 * s; aL = 25 - 35 * s; aR = 25 + 35 * s;
    runLift = Math.abs(Math.cos(((f + phase) / run) * Math.PI * 2)) * 2.5 * u;
  }
  const hipY = -36 * u, shY = -70 * u;
  const leg = (side: -1 | 1, ang: number) => (
    <div key={side} style={{position: 'absolute', left: side * 6 * u, top: hipY, width: 0, height: 0, rotate: `${-ang}deg`}}>
      <Slab x={-3.6 * u} y={0} w={7.2 * u} h={36 * u} color={kit.pants ?? TH.skin} shade={kit.pantsLo ?? TH.skinLo} shadeH={0.2} r={6} />
      {kit.pants ? null : <Slab x={-3.9 * u} y={17 * u} w={7.8 * u} h={16 * u} color={kit.socks} shade="rgba(0,0,0,0.18)" shadeH={0.2} r={4} />}
      <Slab x={-4.2 * u} y={32 * u} w={11 * u} h={4.6 * u} color={kit.shoes} r="30% 60% 20% 20%" />
    </div>
  );
  const arm = (side: -1 | 1, ang: number, held?: React.ReactNode) => (
    <div key={side} style={{position: 'absolute', left: side * 13 * u, top: shY + 1.5 * u, width: 0, height: 0, rotate: `${side * -ang}deg`}}>
      <Slab x={-3 * u} y={9 * u} w={6 * u} h={17 * u} color={kit.coat ? TH.coat : TH.skin} shade={kit.coat ? TH.coatLo : TH.skinLo} shadeH={0.25} r={6} />
      <Slab x={-3.8 * u} y={-1 * u} w={7.6 * u} h={kit.coat ? 18 * u : 11 * u} color={kit.coat ? TH.coat : kit.shirt} shade={kit.coat ? TH.coatLo : kit.shirtLo} shadeH={0.25} r={6} />
      <Disc x={-3.4 * u} y={24.5 * u} d={6.8 * u} color={TH.skin} shade={TH.skinLo} />
      {held ? <div style={{position: 'absolute', left: 0, top: 28 * u, width: 0, height: 0, rotate: `${side * ang}deg`}}>{held}</div> : null}
    </div>
  );
  return (
    <div style={{position: 'absolute', left: x, top: y - lift - runLift + b, width: 0, height: 0, scale: `${face} 1`, rotate: `${lean}deg`}}>
      <Paper lift={6}>
        <div style={{position: 'absolute', left: 0, top: 0, width: 0, height: 0}}>
          {arm(-1, aL)}
          {leg(-1, lL)}{leg(1, lR)}
          {/* shorts */}
          <Slab x={-13 * u} y={-45 * u} w={26 * u} h={13 * u} color={kit.shorts} shade={kit.shortsLo} shadeH={0.25} r="6px 6px 10px 10px" />
          {/* torso */}
          <Slab x={-14 * u} y={shY} w={28 * u} h={kit.coat ? 44 * u : 28 * u} color={kit.coat ? TH.coat : kit.shirt} shade={kit.coat ? TH.coatLo : kit.shirtLo} shadeH={0.14} r="34% 34% 8px 8px" />
          {kit.band ? <Slab x={-14 * u} y={shY + 10 * u} w={28 * u} h={7 * u} color={kit.band} shade={kit.bandLo} shadeH={0.25} r={2} /> : null}
          {kit.coat ? (
            <>
              <Slab x={-4.5 * u} y={shY} w={9 * u} h={20 * u} color="#E4E7EA" r="0 0 30% 30%" />
              <Slab x={-1.1 * u} y={shY + 1.5 * u} w={2.2 * u} h={13 * u} color={TH.ink} r="2px 2px 40% 40%" />
              <div style={{position: 'absolute', left: -7 * u, top: shY + 1 * u, width: 14 * u, height: 15 * u, borderRadius: '50%', border: `${0.7 * u}px solid #3C3F44`, borderTopColor: 'transparent', boxSizing: 'border-box'}} />
              <Disc x={4.6 * u} y={shY + 13.5 * u} d={3.6 * u} color="#B1B9BC" shade="#8C9598" />
            </>
          ) : null}
          {/* neck */}
          <Slab x={-4 * u} y={shY - 5 * u} w={8 * u} h={6.5 * u} color={TH.skin} shade={TH.skinLo} shadeH={0.4} r={3} />
          {arm(1, aR, hold)}
        </div>
      </Paper>
      {/* head outside the Paper filter: the SVG filter region clips tall photo heads */}
      <div style={{position: 'absolute', left: 0, top: shY - 4 * u, width: 0, height: 0}}>{head(u, f)}</div>
      {tag ? (
        <div style={{position: 'absolute', left: 0, top: shY - tagTop * u, scale: `${face} 1`, translate: '-50% 0', background: TH.ink, color: TH.white, fontFamily: 'Bebas Neue', fontSize: Math.max(26, 6 * u), padding: `${0.6 * u}px ${2 * u}px`, letterSpacing: 1, whiteSpace: 'nowrap'}}>{tag}</div>
      ) : null}
    </div>
  );
};

const BOCA: Kit = {shirt: TH.boca, shirtLo: TH.bocaLo, band: TH.oro, bandLo: TH.oroLo, shorts: TH.boca, shortsLo: TH.bocaLo, socks: TH.boca, shoes: TH.ink};

// A Boca player: Boca kit + his real face (magazine cutout with a white paper border, public/cast/<head>.png).
export const Jugador: React.FC<PersonProps & {head: string; name: string}> = ({head, name, ...p}) => (
  <Person tag={name} tagTop={54} {...p} kit={BOCA} head={(u) => (
    <Img src={staticFile(`cast/${head}`)} style={{position: 'absolute', left: -22 * u, top: -42 * u, width: 44 * u, maxWidth: 'none', filter: 'drop-shadow(3px 5px 3px rgba(0,0,0,0.35))'}} />
  )} />
);
// Battaglia (frontal smiling photo) and Paredes (profile photo, from episode 01).
export const Battaglia: React.FC<PersonProps> = (p) => <Jugador head="battaglia-head.png" name="BATTAGLIA" {...p} />;
export const Paredes: React.FC<PersonProps> = (p) => <Jugador head="paredes-head.png" name="PAREDES" {...p} />;

// A generic Boca teammate (drawn face, no real person). Pass `tag` to name the role, or none.
export const Companero: React.FC<PersonProps & {hair?: string}> = ({hair = TH.hair, ...p}) => (
  <Person {...p} kit={BOCA} head={(u, f) => <Head u={u} expr={p.expr ?? 'idle'} hair={hair} f={f} />} />
);

// The doctor: white coat, stethoscope, glasses-free drawn face. Pass hold={<Planilla />} for the clipboard.
export const Medico: React.FC<PersonProps> = (p) => (
  <Person tag="MÉDICO" tagTop={42} {...p} kit={{shirt: TH.coat, shirtLo: TH.coatLo, shorts: '#3B3F46', shortsLo: '#2A2D32', socks: '#3B3F46', shoes: TH.ink, coat: true, pants: '#3B3F46', pantsLo: '#2A2D32'}}
    head={(u, f) => <Head u={u} expr={p.expr ?? 'idle'} hair="#8A8580" f={f} />} />
);

// The coach (DT): black tracksuit and black cap.
export const DT: React.FC<PersonProps> = (p) => (
  <Person tag="DT" tagTop={44} {...p} kit={{shirt: TH.suit, shirtLo: TH.suitLo, shorts: TH.suit, shortsLo: TH.suitLo, socks: TH.suit, shoes: TH.white, cap: true, pants: TH.suit, pantsLo: TH.suitLo}}
    head={(u, f) => <Head u={u} expr={p.expr ?? 'idle'} hair={TH.hair} cap f={f} />} />
);

// Clipboard held in a Person's right hand (drawn around the hand point).
export const Planilla: React.FC<{s?: number}> = ({s = 1}) => (
  <div style={{position: 'absolute', left: -60 * s, top: -40 * s, width: 0, height: 0}}>
    <Paper lift={4}>
      <Slab x={0} y={0} w={120 * s} h={160 * s} color="#B98B5A" shade="#94683F" shadeH={0.08} r={6} />
      <Slab x={10 * s} y={18 * s} w={100 * s} h={132 * s} color={TH.white} r={3} />
      {[0, 1, 2, 3, 4].map((i) => <Slab key={i} x={20 * s} y={(36 + i * 22) * s} w={(i % 2 ? 60 : 80) * s} h={7 * s} color="#BDB8AE" r={3} />)}
      <Slab x={40 * s} y={-6 * s} w={40 * s} h={18 * s} color="#8C9598" r={4} />
    </Paper>
  </div>
);

// ---------- sets ----------

// Pitch with stripes and lines, seen from the side; stands (dark tiers + tiny crowd dots) behind. floorY = touchline.
export const Cancha: React.FC<{floorY?: number; night?: boolean; stands?: boolean}> = ({floorY = 1180, night, stands = true}) => {
  const sky = night ? '#101418' : '#9FB4C2';
  return (
    <div style={{position: 'absolute', inset: 0, background: sky}}>
      {stands ? (
        <>
          {Array.from({length: 7}).map((_, i) => (
            <div key={i} style={{position: 'absolute', left: -40, top: floorY - 640 + i * 78, width: 1160, height: 80, background: i % 2 ? '#2B2E33' : '#33363C', boxShadow: '0 6px 8px rgba(0,0,0,0.35)'}}>
              {Array.from({length: 40}).map((__, k) => {
                const r = ((k * 37 + i * 101) % 97) / 97;
                return <div key={k} style={{position: 'absolute', left: k * 29 + (i % 2) * 12, top: 12 + r * 18, width: 18, height: 26, borderRadius: '45% 45% 20% 20%', background: r > 0.62 ? TH.boca : r > 0.4 ? TH.oro : r > 0.2 ? '#D8D4CA' : '#5A5E66'}} />;
              })}
            </div>
          ))}
          <div style={{position: 'absolute', left: 0, top: floorY - 100, width: 1080, height: 70, background: TH.ink}}>
            {[0, 1, 2].map((i) => <div key={i} style={{position: 'absolute', left: 60 + i * 360, top: 18, width: 240, height: 34, background: TH.white, opacity: 0.9, display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: 'Bebas Neue', fontSize: 30, letterSpacing: 2, color: TH.ink}}>TRIBUNA</div>)}
          </div>
        </>
      ) : null}
      <div style={{position: 'absolute', left: 0, top: floorY - 30, width: 1080, height: 1920 - floorY + 30, background: TH.grass}}>
        {Array.from({length: 6}).map((_, i) => <div key={i} style={{position: 'absolute', left: i * 200 - 40, top: 0, width: 100, height: '100%', background: TH.grassLo, transform: 'skewX(-18deg)'}} />)}
        <div style={{position: 'absolute', left: 0, top: 30, width: 1080, height: 10, background: TH.line, opacity: 0.9}} />
      </div>
    </div>
  );
};

// Locker room: grey lockers, a bench, tiled floor. Used as the club's medical room too (add a Camilla).
export const Vestuario: React.FC<{floorY?: number}> = ({floorY = 1300}) => (
  <div style={{position: 'absolute', inset: 0, background: '#C9C6BF'}}>
    <div style={{position: 'absolute', left: 0, top: 0, width: 1080, height: floorY, background: '#BDB9B1'}} />
    {Array.from({length: 6}).map((_, i) => (
      <div key={i} style={{position: 'absolute', left: 30 + i * 172, top: floorY - 860, width: 160, height: 830}}>
        <Paper lift={3}>
          <Slab x={0} y={0} w={160} h={830} color={i % 2 ? '#3A3D42' : '#43464C'} shade="#2C2E32" shadeH={0.05} r={4}>
            {[0, 1, 2, 3].map((k) => <div key={k} style={{position: 'absolute', left: 40, top: 60 + k * 16, width: 80, height: 7, background: '#26282C', borderRadius: 3}} />)}
            <div style={{position: 'absolute', left: 130, top: 380, width: 12, height: 50, background: '#8C9598', borderRadius: 4}} />
          </Slab>
        </Paper>
      </div>
    ))}
    <div style={{position: 'absolute', left: 0, top: floorY, width: 1080, height: 1920 - floorY, background: '#9C988F'}}>
      {Array.from({length: 9}).map((_, i) => <div key={i} style={{position: 'absolute', left: i * 130, top: 0, width: 2, height: '100%', background: 'rgba(0,0,0,0.12)'}} />)}
    </div>
  </div>
);

// Tactics board: green felt with white pitch lines, metal frame. (x, y, w, h) = the board.
export const Pizarra: React.FC<{x: number; y: number; w: number; h: number; children?: React.ReactNode}> = ({x, y, w, h, children}) => (
  <div style={{position: 'absolute', left: x, top: y, width: w, height: h}}>
    <Paper lift={8}>
      <Slab x={-18} y={-18} w={w + 36} h={h + 36} color="#9AA1A5" shade="#7C8387" shadeH={0.04} r={10} />
      <Slab x={0} y={0} w={w} h={h} color={TH.grass} r={4}>
        <div style={{position: 'absolute', inset: 24, border: `5px solid ${TH.line}`, opacity: 0.8}} />
        <div style={{position: 'absolute', left: w / 2 - 2, top: 24, width: 5, height: h - 48, background: TH.line, opacity: 0.8}} />
        <div style={{position: 'absolute', left: w / 2 - 70, top: h / 2 - 70, width: 140, height: 140, borderRadius: '50%', border: `5px solid ${TH.line}`, opacity: 0.8}} />
        {children}
      </Slab>
    </Paper>
  </div>
);

// A plain paper number sign (numbers are physical props): big digits on a white card, optional word under.
export const NumSign: React.FC<{x: number; y: number; w?: number; big: string; small?: string; color?: string; ink?: string; rot?: number}> = ({x, y, w = 260, big, small, color = TH.white, ink = TH.ink, rot = 0}) => (
  <div style={{position: 'absolute', left: x, top: y, width: w, rotate: `${rot}deg`}}>
    <Paper>
      <Slab x={0} y={0} w={w} h={w * (small ? 1.05 : 0.8)} color={color} shade="#D9D6CF" shadeH={0.08} r={8}>
        <div style={{position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', color: ink}}>
          <div style={{fontFamily: 'Bebas Neue', fontSize: w * 0.62, lineHeight: 0.9}}>{big}</div>
          {small ? <div style={{fontFamily: 'Bebas Neue', fontSize: w * 0.17, letterSpacing: 2}}>{small}</div> : null}
        </div>
      </Slab>
    </Paper>
  </div>
);

export {C};
