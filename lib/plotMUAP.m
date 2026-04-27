function plotMUAP(fsamp, gridData, mask, coordinates, dt, silval, gridIdx, muIdx)
%PLOTMUAP  Plot MUAP of a single MU (Monopolar | Single Differential).
%
%   plotMUAP(fsamp, gridData, mask, coordinates, dt, silval, gridIdx, muIdx)
%
%   Inputs:
%     fsamp       - sampling frequency (Hz)
%     gridData    - [nCh x nSamples] EMG data for this grid only
%     mask        - [nCh x 1] bad-channel flag (1 = discarded by user)
%     coordinates - [nCh x 2] electrode positions (signal.coordinates{g})
%     dt          - discharge sample indices for this MU
%     silval      - SIL value (scalar, NaN if unavailable)
%     gridIdx     - grid index (used only for figure title)
%     muIdx       - MU index (used only for figure title)

winLen_ms = 40;
halfWin   = round(winLen_ms / 1000 * fsamp / 2);
Lsamp     = size(gridData, 2);

ElChMap = coordsToElChMap(coordinates);
if isempty(ElChMap)
    warning('plotMUAP: could not build ElChMap for grid %d', gridIdx);
    return;
end
[nR, nC] = size(ElChMap);

isBad_mono = buildBadMask(ElChMap, mask);
isBad_sd   = isBad_mono(1:end-1,:) | isBad_mono(2:end,:);

tmpl_mono = computeTemplate(gridData, ElChMap, 'mono', dt, halfWin, Lsamp, isBad_mono);
tmpl_sd   = computeTemplate(gridData, ElChMap, 'sd',   dt, halfWin, Lsamp, isBad_sd);

%% Figure — dark theme consistent with MUedit
bgCol    = [0.15   0.15   0.15  ];
fgCol    = [0.9412 0.9412 0.9412];
monoCol  = [0.3804 0.7804 0.749 ];
sdCol    = [0.85   0.33   0.10  ];
badCol   = [0.45   0.45   0.45  ];
fontName = 'Avenir Next';

if ~isnan(silval)
    titleStr = sprintf('Array#%d  |  MU#%d  |  SIL = %.2f', gridIdx, muIdx, silval);
else
    titleStr = sprintf('Array#%d  |  MU#%d', gridIdx, muIdx);
end

fig = figure('Color', bgCol, 'units', 'normalized', 'outerposition', [0 0 1 1]);
tl  = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile(tl);
plotConcatMUAP(tmpl_mono, isBad_mono, nR,   nC, monoCol, badCol, bgCol, fontName, 'Monopolar');

nexttile(tl);
plotConcatMUAP(tmpl_sd,   isBad_sd,   nR-1, nC, sdCol,   badCol, bgCol, fontName, 'Single Differential');

title(tl, titleStr, 'FontName', fontName, 'FontSize', 25, 'Color', fgCol);
end


% =========================================================================
function plotConcatMUAP(tmpl, isBad, nRows, nCols, lineCol, badCol, bgCol, fontName, typeLabel)
winLen = size(tmpl{1,1}, 2);
gapLen = round(winLen / 5);

hold on;
for r = 1:nRows
    row_good = [];
    row_bad  = [];
    for c = 1:nCols
        t = tmpl{r,c};
        if isempty(t), t = zeros(1, winLen); end
        if isBad(r,c)
            row_good = [row_good, NaN(1, winLen)];   %#ok<AGROW>
            row_bad  = [row_bad,  t(:)'];             %#ok<AGROW>
        else
            row_good = [row_good, t(:)'];             %#ok<AGROW>
            row_bad  = [row_bad,  NaN(1, winLen)];   %#ok<AGROW>
        end
        if c < nCols
            row_good = [row_good, NaN(1, gapLen)];   %#ok<AGROW>
            row_bad  = [row_bad,  NaN(1, gapLen)];   %#ok<AGROW>
        end
    end
    plot(row_good + r, 'Color', lineCol, 'LineWidth', 1.5);
    if any(~isnan(row_bad))
        plot(row_bad + r, 'Color', badCol, 'LineWidth', 1.5);
    end
end

title(typeLabel, 'Color', lineCol, 'FontName', fontName, 'FontSize', 14);
ylim([0 nRows+1]);
set(gca, 'Color', bgCol);
axis off;
hold off;
end


% =========================================================================
function tmpl = computeTemplate(gridData, ElChMap, derivType, dt, halfWin, Lsamp, isBad)
% Accesses gridData directly — no intermediate signal cell needed.
% derivType: 'mono' uses row r; 'sd' uses row r minus row r+1.

[nR, nC] = size(ElChMap);
isMono   = strcmp(derivType, 'mono');
nRows    = nR - double(~isMono);   % nR for mono, nR-1 for sd

winLen = 2*halfWin + 1;
tmpl   = cell(nRows, nC);
dt     = dt(dt > halfWin & dt <= Lsamp - halfWin);
nFir   = length(dt);
maxP2P = 0;

for r = 1:nRows
    for c = 1:nC
        ch = ElChMap(r,c);

        if isMono
            if ch == 0, tmpl{r,c} = zeros(1, winLen); continue; end
            sig_rc = gridData(ch,:);
        else
            ch2 = ElChMap(r+1,c);
            if ch == 0 || ch2 == 0, tmpl{r,c} = zeros(1, winLen); continue; end
            sig_rc = gridData(ch,:) - gridData(ch2,:);
        end

        if nFir < 2, tmpl{r,c} = zeros(1, winLen); continue; end

        wins = zeros(nFir, winLen);
        for f = 1:nFir
            wins(f,:) = sig_rc(dt(f)-halfWin : dt(f)+halfWin);
        end
        t = mean(wins, 1);
        t = t - mean(t);
        tmpl{r,c} = t;
        if ~isBad(r,c)
            p2p = peak2peak(t);
            if p2p > maxP2P, maxP2P = p2p; end
        end
    end
end

if maxP2P > 0
    for r = 1:nRows
        for c = 1:nC
            tmpl{r,c} = tmpl{r,c} / maxP2P;
        end
    end
end
end


% =========================================================================
function isBad = buildBadMask(ElChMap, mask)
[nR, nC] = size(ElChMap);
isBad = false(nR, nC);
for r = 1:nR
    for c = 1:nC
        ch = ElChMap(r,c);
        isBad(r,c) = (ch == 0 || mask(ch) == 1);
    end
end
end


% =========================================================================
function ElChMap = coordsToElChMap(coords)
nR = max(coords(:,1));
nC = max(coords(:,2));
ElChMap = zeros(nR, nC);
for ch = 1:size(coords, 1)
    r = coords(ch,1);
    c = coords(ch,2);
    if r > 0 && c > 0
        ElChMap(r,c) = ch;
    end
end
end
