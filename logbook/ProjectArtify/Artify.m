function ArtifyUI()
% ARTIFYUI - Professional UI for Artify Painting Studio (Fast Edition)

%% ─────────────────────────────────────────────
%  Application State
% ─────────────────────────────────────────────
state = struct(...
    'mode',          'none', ...
    'style',         'oil', ...
    'isRunning',     false, ...
    'cam',           [], ...
    'uploadedImg',   [], ...
    'timerObj',      [], ...
    'brushIntensity',0.7, ...
    'colorBoost',    1.3, ...
    'outputFrames',  [], ...
    'canvas',        [], ...
    'revealMask',    [], ...
    'allStrokes',    [], ...
    'strokeIdx',     0, ...
    'segIdx',        0, ...
    'nSegsTotal',    0, ...
    'nTotal',        0, ...
    'finalArt',      [], ...
    'brushImg',      [], ...
    'hImg',          [], ...
    'nFrames',       0, ...
    'frames',        [], ...
    'frameIdx',      1, ...
    'saveEvery',     1  ...
);

%% ─────────────────────────────────────────────
%  Colour Palette
% ─────────────────────────────────────────────
C = struct(...
    'bg',      [0.08 0.08 0.10], ...
    'panel',   [0.12 0.12 0.15], ...
    'card',    [0.16 0.16 0.20], ...
    'accent',  [0.95 0.65 0.20], ...
    'text',    [0.95 0.93 0.88], ...
    'subtext', [0.60 0.58 0.55], ...
    'success', [0.30 0.85 0.55], ...
    'danger',  [0.95 0.35 0.35], ...
    'btnFace', [0.22 0.22 0.27]  ...
);

%% ─────────────────────────────────────────────
%  Main Figure
% ─────────────────────────────────────────────
fig = figure(...
    'Name',           'Artify — Painting Studio', ...
    'NumberTitle',    'off', ...
    'MenuBar',        'none', ...
    'ToolBar',        'none', ...
    'Color',          C.bg, ...
    'Units',          'normalized', ...
    'Position',       [0 0 1 1], ...
    'Resize',         'on', ...
    'CloseRequestFcn',@onClose);
% Maximize to fill screen
try
    jFrame = get(fig, 'JavaFrame'); %#ok<JAVFM>
    jFrame.setMaximized(true);
catch
    set(fig, 'WindowState', 'maximized');  % R2018a+
end

%% ─────────────────────────────────────────────
%  Panels
% ─────────────────────────────────────────────
leftPanel = uipanel(fig,'BackgroundColor',C.panel,'BorderType','none',...
    'Units','normalized','Position',[0 0 0.22 1]);
canvasPanel = uipanel(fig,'BackgroundColor',C.bg,'BorderType','none',...
    'Units','normalized','Position',[0.22 0 0.56 1]);
rightPanel = uipanel(fig,'BackgroundColor',C.panel,'BorderType','none',...
    'Units','normalized','Position',[0.78 0 0.22 1]);

%% ─────────────────────────────────────────────
%  LEFT PANEL
% ─────────────────────────────────────────────
uicontrol(leftPanel,'Style','text','String','ARTIFY',...
    'FontName','Helvetica','FontSize',26,'FontWeight','bold',...
    'ForegroundColor',C.accent,'BackgroundColor',C.panel,...
    'Units','normalized','Position',[0.05 0.91 0.90 0.07]);
uicontrol(leftPanel,'Style','text','String','Painting Studio',...
    'FontName','Helvetica','FontSize',10,...
    'ForegroundColor',C.subtext,'BackgroundColor',C.panel,...
    'Units','normalized','Position',[0.05 0.87 0.90 0.04]);
divider(leftPanel,C,0.864);

makeSectionLabel(leftPanel,C,'INPUT SOURCE',0.82);
btnWebcam = makeBtn(leftPanel,C,'  Live Webcam',[0.05 0.750 0.90 0.065],@onWebcamSelect);
btnUpload = makeBtn(leftPanel,C,'  Upload Image',[0.05 0.675 0.90 0.065],@onUploadSelect);
setBtnActive(btnWebcam,C,false);
setBtnActive(btnUpload,C,false);

makeSectionLabel(leftPanel,C,'PAINTING STYLE',0.625);
styleKeys  = {'oil','watercolor','impressionist','sketch'};
styleNames = {'Oil Paint','Watercolor','Impressionist','Pencil Sketch'};
styleYPos  = [0.555 0.480 0.405 0.330];
styleButtons = gobjects(1,4);
for s = 1:4
    styleButtons(s) = makeBtn(leftPanel,C,styleNames{s},...
        [0.05 styleYPos(s) 0.90 0.065],@(src,~) onStyleSelect(s));
end
setBtnActive(styleButtons(1),C,true);

makeSectionLabel(leftPanel,C,'PARAMETERS',0.285);
uicontrol(leftPanel,'Style','text','String','Brush Intensity',...
    'FontName','Helvetica','FontSize',9,'ForegroundColor',C.subtext,...
    'BackgroundColor',C.panel,'HorizontalAlignment','left',...
    'Units','normalized','Position',[0.06 0.252 0.88 0.028]);
uicontrol(leftPanel,'Style','slider','Min',0.1,'Max',1.0,'Value',0.7,...
    'BackgroundColor',C.btnFace,'Units','normalized','Position',[0.05 0.222 0.90 0.025],...
    'Callback',@(s,~) setfield_state('brushIntensity',s.Value));
uicontrol(leftPanel,'Style','text','String','Colour Boost',...
    'FontName','Helvetica','FontSize',9,'ForegroundColor',C.subtext,...
    'BackgroundColor',C.panel,'HorizontalAlignment','left',...
    'Units','normalized','Position',[0.06 0.190 0.88 0.028]);
uicontrol(leftPanel,'Style','slider','Min',0.5,'Max',2.5,'Value',1.3,...
    'BackgroundColor',C.btnFace,'Units','normalized','Position',[0.05 0.160 0.90 0.025],...
    'Callback',@(s,~) setfield_state('colorBoost',s.Value));

divider(leftPanel,C,0.148);
btnStart = uicontrol(leftPanel,'Style','pushbutton','String','  START',...
    'FontName','Helvetica','FontSize',12,'FontWeight','bold',...
    'ForegroundColor',[0.08 0.08 0.10],'BackgroundColor',C.accent,...
    'Units','normalized','Position',[0.05 0.078 0.90 0.062],...
    'Callback',@onStart,'Enable','off');
btnStop = uicontrol(leftPanel,'Style','pushbutton','String','  STOP',...
    'FontName','Helvetica','FontSize',12,'FontWeight','bold',...
    'ForegroundColor',C.text,'BackgroundColor',C.danger,...
    'Units','normalized','Position',[0.05 0.010 0.90 0.062],...
    'Callback',@onStop,'Enable','off');

%% ─────────────────────────────────────────────
%  CENTRE CANVAS
% ─────────────────────────────────────────────
lblStatus = uicontrol(canvasPanel,'Style','text','String','Select a mode to begin',...
    'FontName','Helvetica','FontSize',9,'ForegroundColor',C.subtext,...
    'BackgroundColor',C.bg,'HorizontalAlignment','right',...
    'Units','normalized','Position',[0.02 0.955 0.96 0.034]);

% Canvas title labels — placed as uicontrols ABOVE the axes, never clipped
uicontrol(canvasPanel,'Style','text','String','Original',...
    'FontName','Helvetica','FontSize',10,'FontWeight','bold',...
    'ForegroundColor',C.subtext,'BackgroundColor',C.bg,...
    'HorizontalAlignment','center',...
    'Units','normalized','Position',[0.02 0.915 0.46 0.034]);
uicontrol(canvasPanel,'Style','text','String','Artistic Output',...
    'FontName','Helvetica','FontSize',10,'FontWeight','bold',...
    'ForegroundColor',C.subtext,'BackgroundColor',C.bg,...
    'HorizontalAlignment','center',...
    'Units','normalized','Position',[0.52 0.915 0.46 0.034]);

% Axes: sit below the title labels, above the progress bar
axOrig = makeCanvas(canvasPanel,[0.02 0.08 0.46 0.825],'',C);
axArt  = makeCanvas(canvasPanel,[0.52 0.08 0.46 0.825],'',C);
showPlaceholder(axOrig,C,'Original');
showPlaceholder(axArt, C,'Artistic Output');

% Dynamic art-canvas subtitle (shows style name / progress) — separate from fixed label
lblArtTitle = uicontrol(canvasPanel,'Style','text','String','',...
    'FontName','Helvetica','FontSize',9,'ForegroundColor',C.subtext,...
    'BackgroundColor',C.bg,'HorizontalAlignment','center',...
    'Units','normalized','Position',[0.52 0.915 0.46 0.034]);

% Progress bar (image mode)
uipanel(canvasPanel,'BackgroundColor',[0.15 0.15 0.18],'BorderType','none',...
    'Units','normalized','Position',[0.02 0.022 0.96 0.038],'Tag','progBg');
progFill = uipanel(canvasPanel,'BackgroundColor',C.accent,'BorderType','none',...
    'Units','normalized','Position',[0.02 0.022 0.001 0.038],'Tag','progFill');
lblProg = uicontrol(canvasPanel,'Style','text','String','',...
    'FontName','Helvetica','FontSize',9,'ForegroundColor',C.text,...
    'BackgroundColor',[0.15 0.15 0.18],...
    'Units','normalized','Position',[0.02 0.022 0.96 0.038],'Tag','lblProg');
% Hide progress initially
set(findobj(canvasPanel,'Tag','progBg'),'Visible','off');
set(progFill,'Visible','off');
set(lblProg,'Visible','off');

%% ─────────────────────────────────────────────
%  RIGHT PANEL
% ─────────────────────────────────────────────
uicontrol(rightPanel,'Style','text','String','INFO',...
    'FontName','Helvetica','FontSize',11,'FontWeight','bold',...
    'ForegroundColor',C.text,'BackgroundColor',C.panel,...
    'Units','normalized','Position',[0.05 0.91 0.90 0.06]);
divider(rightPanel,C,0.906);

statsCard = uipanel(rightPanel,'BackgroundColor',C.card,'BorderType','none',...
    'Units','normalized','Position',[0.05 0.70 0.90 0.195]);
lblMode  = makeStatRow(statsCard,C,'Mode',   '—',0.72);
lblStyle = makeStatRow(statsCard,C,'Style',  '—',0.50);
lblFPS   = makeStatRow(statsCard,C,'FPS',    '—',0.28);
lblRes   = makeStatRow(statsCard,C,'Size',   '—',0.06);

makeSectionLabel(rightPanel,C,'EXPORT',0.660);
makeBtn(rightPanel,C,'  Save Image',[0.05 0.595 0.90 0.055],@onSaveImage);
makeBtn(rightPanel,C,'  Save Timelapse',[0.05 0.530 0.90 0.055],@onSaveVideo);

makeSectionLabel(rightPanel,C,'TIPS',0.490);
tipCard = uipanel(rightPanel,'BackgroundColor',C.card,'BorderType','none',...
    'Units','normalized','Position',[0.05 0.040 0.90 0.440]);
uicontrol(tipCard,'Style','text',...
    'String',sprintf(['Sketch is fastest for live\n'...
        'video — try it first.\n\n'...
        'Oil & Watercolor look\n'...
        'best on photos.\n\n'...
        'Lower Brush Intensity\n'...
        'speeds up processing.\n\n'...
        'Timelapse saves after\n'...
        'image processing.']),...
    'FontName','Helvetica','FontSize',8.5,...
    'ForegroundColor',C.subtext,'BackgroundColor',C.card,...
    'HorizontalAlignment','left',...
    'Units','normalized','Position',[0.08 0.04 0.84 0.92]);

%% ─────────────────────────────────────────────
%  Stored handles
% ─────────────────────────────────────────────
H.fig=fig; H.axOrig=axOrig; H.axArt=axArt;
H.btnStart=btnStart; H.btnStop=btnStop;
H.btnWebcam=btnWebcam; H.btnUpload=btnUpload;
H.styleButtons=styleButtons;
H.lblStatus=lblStatus; H.lblMode=lblMode; H.lblStyle=lblStyle;
H.lblFPS=lblFPS; H.lblRes=lblRes;
H.progFill=progFill; H.lblProg=lblProg;
H.lblArtTitle=lblArtTitle;
H.C=C; H.styleKeys=styleKeys; H.styleNames=styleNames;
guidata(fig,H);

%% ═══════════════════════════════════════════
%  CALLBACKS
%% ═══════════════════════════════════════════

    function onWebcamSelect(~,~)
        state.mode = 'webcam';
        H = guidata(fig);
        setBtnActive(H.btnWebcam,C,true);
        setBtnActive(H.btnUpload,C,false);
        set(H.btnStart,'Enable','on');
        set(H.lblMode,'String','Live Webcam');
        set(H.lblStatus,'String','Webcam selected — press START');
        showPlaceholder(H.axOrig,C,'Camera Feed');
        showPlaceholder(H.axArt, C,'Live Art');
    end

    function onUploadSelect(~,~)
        [f,p] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.tiff','Images'},'Select Image');
        if isequal(f,0), return; end
        img = imread(fullfile(p,f));
        img = limitSize(img, 640);
        state.uploadedImg = img;
        state.mode = 'image';
        H = guidata(fig);
        setBtnActive(H.btnWebcam,C,false);
        setBtnActive(H.btnUpload,C,true);
        set(H.btnUpload,'String','  Change Image');   % update label
        set(H.btnStart,'Enable','on');
        set(H.lblMode,'String','Image Upload');
        [r,c,~] = size(img);
        set(H.lblRes,'String',sprintf('%dx%d',c,r));
        set(H.lblStatus,'String',sprintf('Loaded: %s',f));
        imshow(img,'Parent',H.axOrig);
        set(H.lblArtTitle,'String','');
        showPlaceholder(H.axArt,C,'Press START');
    end

    function onStyleSelect(idx)
        state.style = styleKeys{idx};
        for k=1:4, setBtnActive(styleButtons(k),C,k==idx); end
        H = guidata(fig);
        set(H.lblStyle,'String',styleNames{idx});
    end

    function setfield_state(field, val)
        state.(field) = val;
    end

    function onStart(~,~)
        if strcmp(state.mode,'none'), return; end
        H = guidata(fig);
        state.isRunning = true;
        set(H.btnStart,'Enable','off');
        set(H.btnStop,'Enable','on');
        if strcmp(state.mode,'webcam')
            startWebcam(H);
        else
            processImage(H);
        end
    end

    function onStop(~,~)
        state.isRunning = false;
        H = guidata(fig);
        set(H.btnStart,'Enable','on');
        set(H.btnStop,'Enable','off');
        set(H.lblStatus,'String','Stopped.');
        set(H.lblFPS,'String','—');
        if ~isempty(state.timerObj) && isvalid(state.timerObj)
            stop(state.timerObj); delete(state.timerObj);
        end
        state.timerObj = [];
        if ~isempty(state.cam)
            try, release(state.cam); catch, end
            state.cam = [];
        end
    end

    function onSaveImage(~,~)
        H = guidata(fig);
        [f,p] = uiputfile({'*.png','PNG';'*.jpg','JPEG'},'Save Image','artify_output.png');
        if isequal(f,0), return; end
        try
            fr = getframe(H.axArt);
            imwrite(fr.cdata, fullfile(p,f));
            set(H.lblStatus,'String',['Saved: ' f]);
        catch e
            errordlg(e.message,'Save Error');
        end
    end

    function onSaveVideo(~,~)
        if isempty(state.outputFrames)
            msgbox('Process an image first.','No Timelapse','warn'); return;
        end
        [f,p] = uiputfile({'*.mp4','MP4';'*.avi','AVI'},'Save Timelapse','artify_timelapse.mp4');
        if isequal(f,0), return; end
        try
            ext = lower(f(end-2:end));
            if strcmp(ext,'mp4'), fmt='MPEG-4'; else, fmt='Motion JPEG AVI'; end
            vw = VideoWriter(fullfile(p,f),fmt);
            vw.FrameRate = 24;
            open(vw);
            for i=1:length(state.outputFrames)
                writeVideo(vw, state.outputFrames{i});
            end
            close(vw);
            H = guidata(fig); %#ok
            set(H.lblStatus,'String',['Timelapse saved: ' f]);
        catch e
            errordlg(e.message,'Save Error');
        end
    end

    function onClose(~,~)
        state.isRunning = false;
        if ~isempty(state.timerObj) && isvalid(state.timerObj)
            stop(state.timerObj); delete(state.timerObj);
        end
        if ~isempty(state.cam)
            try, release(state.cam); catch, end
        end
        delete(fig);
    end

%% ═══════════════════════════════════════════
%  WEBCAM LOOP
%% ═══════════════════════════════════════════

    function startWebcam(H)
        set(H.lblStatus,'String','Connecting to webcam...'); drawnow;
        try
            state.cam = webcam(1);
        catch e
            errordlg(['Webcam: ' e.message],'Error');
            set(H.btnStart,'Enable','on'); set(H.btnStop,'Enable','off'); return;
        end
        try, res = state.cam.Resolution; set(H.lblRes,'String',res); catch, end
        set(H.lblStatus,'String','Live — streaming');
        state.timerObj = timer('ExecutionMode','fixedRate','Period',0.08,...
            'TimerFcn',@camTick,'ErrorFcn',@(~,~)onStop([],[]));
        start(state.timerObj);
    end

    function camTick(~,~)
        if ~state.isRunning || isempty(state.cam), return; end
        try
            t0 = tic;
            frame = snapshot(state.cam);
            % Downscale for speed: process at 320px wide
            small = limitSize(frame, 320);
            art   = fastPaintEffect(small, state.style, ...
                        state.brushIntensity, state.colorBoost);
            % Upscale result back to original for display
            art = imresize(art, [size(frame,1) size(frame,2)]);
            H = guidata(fig);
            if ~isvalid(fig), return; end
            imshow(frame,'Parent',H.axOrig);
            
            imshow(art,'Parent',H.axArt);
            set(H.lblArtTitle,'String',styleLabel(state.style));
            fps = 1/max(toc(t0),0.001);
            set(H.lblFPS,'String',sprintf('%.0f fps',min(fps,60)));
            drawnow limitrate;
        catch
        end
    end

%% ═══════════════════════════════════════════
%  IMAGE + TIMELAPSE
%% ═══════════════════════════════════════════

    function processImage(H)
        img = state.uploadedImg;
        set(H.lblStatus,'String','Painting timelapse...');
        set(findobj(fig,'Tag','progBg'),'Visible','on');
        set(H.progFill,'Visible','on');
        set(H.lblProg,'Visible','on');
        drawnow;

        state.finalArt = fastPaintEffect(img, state.style, ...
                             state.brushIntensity, state.colorBoost);
        [r, c, ~] = size(img);

        grayA = im2double(rgb2gray(state.finalArt));
        Ix = imfilter(grayA, fspecial('sobel')', 'replicate');
        Iy = imfilter(grayA, fspecial('sobel'),  'replicate');

        rng(42);
        passes = {
            [18, round(c*0.25), round(c*0.40), round(r*0.08), round(r*0.13)],
            [40, round(c*0.12), round(c*0.22), round(r*0.04), round(r*0.08)],
            [70, round(c*0.04), round(c*0.10), round(r*0.015),round(r*0.04)]
        };
        allStrokes = zeros(0,5);
        for p = 1:3
            ps  = passes{p};  nS = ps(1);
            cxs = randi([1 c], nS, 1);
            cys = randi([1 r], nS, 1);
            lens = ps(2) + randi(max(1,ps(3)-ps(2)), nS, 1);
            wids = ps(4) + randi(max(1,ps(5)-ps(4)), nS, 1);
            idx  = sub2ind([r c], min(r,max(1,cys)), min(c,max(1,cxs)));
            angs = atan2(-Ix(idx), Iy(idx)) + (rand(nS,1)-0.5)*0.5;
            allStrokes = [allStrokes; cxs cys angs lens wids]; %#ok
        end
        rng('shuffle');

        state.allStrokes = allStrokes;
        state.nTotal     = size(allStrokes,1);

        % Canvas starts as off-white — revealed pixels come from finalArt
        state.canvas     = uint8(ones(r,c,3)*245);
        % Accumulate reveal mask (0=canvas, 1=finalArt shown)
        state.revealMask = zeros(r, c, 'single');

        state.strokeIdx  = 1;
        state.segIdx     = 0;
        state.nSegsTotal = 3;
        state.nFrames    = 40;
        state.frames     = cell(1,40);
        state.frameIdx   = 1;
        state.saveEvery  = max(1, floor(state.nTotal/40));

        brushR = max(5, round(min(r,c)*0.022));
        state.brushImg = makeToolIcon(brushR, state.style, C.accent);

        % Show blank canvas to start
        state.hImg = imshow(state.canvas, 'Parent', H.axArt);

        state.timerObj = timer(...
            'ExecutionMode', 'fixedRate', ...
            'Period',        0.028, ...
            'TimerFcn',      @strokeTick, ...
            'ErrorFcn',      @(~,~) onStop([],[]));
        start(state.timerObj);
    end

    function strokeTick(~,~)
        if ~state.isRunning, return; end

        si   = state.strokeIdx;
        nSeg = state.nSegsTotal;

        % All strokes done — smoothly fill remaining gaps
        if si > state.nTotal
            stop(state.timerObj); delete(state.timerObj); state.timerObj = [];
            H = guidata(fig); if ~isvalid(fig), return; end

            % Ease remaining uncovered pixels in over ~0.7s
            nFade     = 25;
            startMask = state.revealMask;
            canvasD   = double(state.canvas);
            finalD    = double(state.finalArt);
            fadeFrames = cell(1, nFade);
            for fi = 1:nFade
                t  = fi / nFade;
                te = t*t*(3 - 2*t);                        % ease in-out
                rm = startMask + (1 - startMask) .* te;   % fill gaps
                blended = uint8(canvasD .* (1-rm) + finalD .* rm);
                set(state.hImg, 'CData', blended);
                drawnow;
                pause(0.028);
                fadeFrames{fi} = blended;
            end
            % Append fade frames to export video
            existingFrames = state.outputFrames;
            if isempty(existingFrames), existingFrames = {}; end
            existingFrames = existingFrames(~cellfun(@isempty, existingFrames));
            state.outputFrames = [existingFrames, fadeFrames];

            set(H.lblArtTitle,'String',[styleLabel(state.style) ' — Done ✓']);
            set(H.progFill,'Position',[0.02 0.022 0.96 0.038],'BackgroundColor',C.success);
            set(H.lblProg,'String','Done!  Use export buttons');
            set(H.lblStatus,'String','Complete — ready to export');
            set(H.btnStart,'Enable','on'); set(H.btnStop,'Enable','off');
            state.isRunning = false;
            return;
        end

        sx  = state.allStrokes(si,1);  sy  = state.allStrokes(si,2);
        ang = state.allStrokes(si,3);  len = state.allStrokes(si,4);
        wid = state.allStrokes(si,5);
        [r, c, ~] = size(state.canvas);

        % Advance segment
        state.segIdx = state.segIdx + 1;
        seg      = state.segIdx;
        segFrac  = seg / nSeg;
        partLen  = len * segFrac;

        % Stroke grows from tail toward tip
        halfFull = len / 2;
        tailX = sx - halfFull * cos(ang);
        tailY = sy - halfFull * sin(ang);
        partCx = round(tailX + partLen/2 * cos(ang));
        partCy = round(tailY + partLen/2 * sin(ang));

        % Build stroke alpha mask for this partial length
        strokeAlpha = buildStrokeMask(partCx, partCy, ang, partLen, wid, r, c);

        % Accumulate into reveal mask
        state.revealMask = min(single(1), state.revealMask + strokeAlpha);

        % Composite only the dirty bounding box — much faster than full image
        halfL2 = partLen/2;  halfW2 = wid/2;  cosA = cos(ang);  sinA = sin(ang);
        hw2 = ceil(abs(halfL2*cosA)+abs(halfW2*sinA))+3;
        hh2 = ceil(abs(halfL2*sinA)+abs(halfW2*cosA))+3;
        dx1=max(1,partCx-hw2); dx2=min(c,partCx+hw2);
        dy1=max(1,partCy-hh2); dy2=min(r,partCy+hh2);

        rm = state.revealMask(dy1:dy2, dx1:dx2);
        for ch = 1:3
            bg  = double(state.canvas(dy1:dy2,dx1:dx2,ch));
            art = double(state.finalArt(dy1:dy2,dx1:dx2,ch));
            state.canvas(dy1:dy2,dx1:dx2,ch) = uint8(bg.*(1-rm) + art.*rm);
        end

        % Brush icon at leading tip
        tipX = min(c,max(1, round(tailX + partLen*cos(ang))));
        tipY = min(r,max(1, round(tailY + partLen*sin(ang))));
        displayFrame = overlayBrush(state.canvas, state.brushImg, tipX, tipY);
        try, set(state.hImg, 'CData', displayFrame); catch, return; end

        pct = (si-1+segFrac) / state.nTotal;
        H = guidata(fig);
        set(H.lblArtTitle,'String',sprintf('Painting... %d%%', round(pct*100)));
        set(H.progFill,'Position',[0.02 0.022 0.96*pct 0.038]);
        set(H.lblProg,'String',sprintf('Stroke %d / %d', si, state.nTotal));

        if seg >= nSeg
            fullAlpha = buildStrokeMask(sx, sy, ang, len, wid, r, c);
            newMask = min(single(1), state.revealMask + fullAlpha);
            changed = newMask > state.revealMask;
            if any(changed(:))
                for ch=1:3
                    bg2  = double(state.canvas(:,:,ch));
                    art2 = double(state.finalArt(:,:,ch));
                    bg2(changed) = art2(changed);
                    state.canvas(:,:,ch) = uint8(bg2);
                end
            end
            state.revealMask = newMask;
            state.strokeIdx = si + 1;
            state.segIdx    = 0;
            if mod(si, state.saveEvery)==0 || si==state.nTotal
                % Save full composite (white bg + all revealed pixels so far)
                trueFrame = uint8(double(uint8(ones(r,c,3)*245)) .* (1-double(state.revealMask)) + ...
                                  double(state.finalArt) .* double(state.revealMask));
                state.frames{min(state.frameIdx,state.nFrames)} = trueFrame;
                state.frameIdx = state.frameIdx+1;
            end
            state.outputFrames = state.frames;
        end
    end

end % ArtifyUI

%% ═══════════════════════════════════════════════════════════════════════
%  FAST PAINT EFFECTS  (all vectorised, no pixel loops)
%% ═══════════════════════════════════════════════════════════════════════

function out = fastPaintEffect(img, style, intensity, colorBoost)
% Dispatch to lightweight effect. Input/output: uint8 RGB.
    switch style
        case 'oil',           out = fxOil(img, intensity, colorBoost);
        case 'watercolor',    out = fxWatercolor(img, intensity, colorBoost);
        case 'impressionist', out = fxImpressionist(img, intensity, colorBoost);
        case 'sketch',        out = fxSketch(img, intensity);
        otherwise,            out = fxOil(img, intensity, colorBoost);
    end
end

% ── Oil Paint ─────────────────────────────────────────────────────────────
% Posterised colour regions with hard boundaries — looks like thick layered paint.
% Key trick: quantise colours into flat zones, then draw sharp edges back on top.
function out = fxOil(img, intensity, colorBoost)
    d = im2double(img);

    % 1. Smooth to merge nearby colours (paint mixes on canvas)
    r   = max(2, round(intensity * 5));
    smt = zeros(size(d), 'uint8');
    for ch = 1:3
        smt(:,:,ch) = medfilt2(img(:,:,ch), [r*2+1 r*2+1]);
    end
    smt = im2double(smt);

    % 2. Posterise: quantise each channel to N levels → flat colour zones
    levels = max(4, round(8 - intensity * 3));   % fewer levels = chunkier look
    smt = round(smt * levels) / levels;

    % 3. Boost saturation heavily — oil pigment is vivid
    smt = boostSatD(smt, colorBoost * 1.6);
    smt = clamp01mat(smt);

    % 4. Detect edges on original and burn them back in as dark outlines
    gray  = rgb2gray(d);
    edgeMap = edge(gray, 'sobel', graythresh(gray) * 0.4);
    edgeMap = imdilate(edgeMap, strel('disk', 1));
    edgeMap = imgaussfilt(double(edgeMap), 0.8);
    edgeMask = repmat(1 - 0.75*edgeMap, [1 1 3]);

    out = uint8(clampU8(smt .* edgeMask * 255));
end

% ── Watercolor ────────────────────────────────────────────────────────────
% Real watercolour look: flat simplified colour regions (like wet paint puddles),
% hard dark outlines where regions meet, white paper showing through in lights,
% and a rough paper texture. NO blurring of the whole image.
function out = fxWatercolor(img, intensity, colorBoost)
    d    = im2double(img);
    gray = im2double(rgb2gray(img));
    [rows, cols, ~] = size(d);

    % 1. SIMPLIFY colours into flat wash regions
    %    Quantise hue/sat/val so nearby colours merge into solid puddles
    hsv = rgb2hsv(d);
    levels = max(5, round(10 - intensity * 4));
    hsv(:,:,1) = round(hsv(:,:,1) * levels) / levels;          % posterise hue
    hsv(:,:,2) = round(hsv(:,:,2) * (levels-1)) / (levels-1);  % posterise sat
    hsv(:,:,3) = round(hsv(:,:,3) * levels) / levels;          % posterise val
    flat = hsv2rgb(hsv);

    % 2. Lightly smooth each flat region (wet paint spreads within puddle)
    flat = imgaussfilt(flat, max(1, intensity * 2));

    % 3. Lighten toward white — diluted watercolour paint on white paper
    %    Bright areas almost disappear, mid-tones stay coloured
    flat = flat * 0.72 + 0.22;
    flat = boostSatD(flat, colorBoost * 1.1);

    % 4. GRANULATION: watercolour pigment settles unevenly in the wash
    %    Simulate by multiplying in low-freq noise that follows value contours
    gran_noise = imgaussfilt(rand(rows, cols) * 0.18, max(2, intensity*4));
    gran_noise = gran_noise - mean(gran_noise(:));   % zero-mean
    flat = flat + repmat(gran_noise, [1 1 3]) .* repmat(1-gray, [1 1 3]);
    flat = clamp01mat(flat);

    % 5. SOFT PIGMENT POOLING at edges — NO hard black lines
    %    Real watercolour: pigment drifts and concentrates slightly at wash edges
    %    but it's a gentle colour shift, never a crisp outline
    %    Use gradient of the smoothed image — soft transitions only
    grayFlat  = im2double(rgb2gray(flat));
    Ix = imfilter(grayFlat, fspecial('sobel')', 'replicate');
    Iy = imfilter(grayFlat, fspecial('sobel'),  'replicate');
    gradSoft  = clamp01mat(sqrt(Ix.^2 + Iy.^2) * 3);
    bloom     = imgaussfilt(gradSoft, max(3, intensity * 5));  % very soft spread
    bloom     = bloom * 0.35;   % keep it subtle — just a tonal shift
    hsvF = rgb2hsv(flat);
    hsvF(:,:,3) = clamp01mat(hsvF(:,:,3) - bloom * 0.30);   % slightly darker
    hsvF(:,:,2) = clamp01mat(hsvF(:,:,2) + bloom * 0.15);   % slightly more saturated
    flat = hsv2rgb(hsvF);

    % 6. Rough watercolour PAPER TEXTURE
    %    Coarse high-frequency grain, stronger in mid-tones
    paper = rand(rows, cols) * 0.07 - 0.035;
    paper = paper .* (1 - abs(gray - 0.5) * 0.5);  % less grain in pure black/white
    flat  = flat + repmat(paper, [1 1 3]);

    % 7. White paper bleeds through in the lightest areas
    lightMask = clamp01mat((gray - 0.6) * 3.5);
    flat = flat + repmat(lightMask * 0.3, [1 1 3]);

    out = uint8(clampU8(clamp01mat(flat) * 255));
end

% ── Impressionist ─────────────────────────────────────────────────────────
% Visible dab-like paint marks across the whole image, like Monet/Van Gogh.
% Key: spatial colour dithering + cross-directional strokes = textured surface.
function out = fxImpressionist(img, intensity, colorBoost)
    d = im2double(img);
    [rows, cols, ~] = size(d);

    % 1. Create a canvas of random small colour dabs
    %    Tile image into small blocks and jitter each block's colour slightly
    blockSize = max(4, round(intensity * 10));
    canvas = d;
    for y = 1:blockSize:rows
        for x = 1:blockSize:cols
            y2 = min(y+blockSize-1, rows);
            x2 = min(x+blockSize-1, cols);
            % Sample centre colour of block
            cy = round((y+y2)/2); cx = round((x+x2)/2);
            col = squeeze(d(cy, cx, :))';
            % Jitter the colour (individual dab variation)
            jitter = (rand(1,3) - 0.5) * 0.12 * intensity;
            col = clamp01mat(col + jitter);
            canvas(y:y2, x:x2, 1) = col(1);
            canvas(y:y2, x:x2, 2) = col(2);
            canvas(y:y2, x:x2, 3) = col(3);
        end
    end

    % 2. Apply a short directional stroke blur to elongate the dabs
    L  = max(5, round(intensity * 12));
    h1 = fspecial('motion', L, 35);
    h2 = fspecial('motion', L, 125);
    s1 = imfilter(canvas, h1, 'replicate');
    s2 = imfilter(canvas, h2, 'replicate');
    canvas = 0.5*s1 + 0.5*s2;

    % 3. Mix with original structure so shapes are still readable
    canvas = 0.70*canvas + 0.30*d;

    % 4. Strong saturation — impressionists painted with pure colour
    canvas = boostSatD(canvas, colorBoost * 1.7);

    % 5. Slight warm tone shift
    canvas(:,:,1) = clamp01mat(canvas(:,:,1) * 1.08);
    canvas(:,:,3) = clamp01mat(canvas(:,:,3) * 0.90);

    out = uint8(clampU8(clamp01mat(canvas) * 255));
end

% ── Pencil Sketch ─────────────────────────────────────────────────────────
% Imperfect hand-drawn pencil look: wobbly lines, uneven pressure, smudged
% shading, slightly off-white paper. NOT a clean digital filter.
function out = fxSketch(img, intensity)
    d    = im2double(img);
    gray = im2double(rgb2gray(img));
    [rows, cols] = size(gray);

    % 1. OUTLINE LAYER via dodge — core pencil line extraction
    inv   = 1 - gray;
    sig   = max(6, intensity * 20);
    dodge = imgaussfilt(inv, sig);
    lines = clamp01mat(gray ./ max(0.01, 1 - dodge));

    % 2. ADD HAND TREMOR: warp the line layer with small spatial displacement
    %    Real pencil lines are never perfectly straight
    [gx, gy] = meshgrid(1:cols, 1:rows);
    jitterAmt = intensity * 1.8;
    dx = jitterAmt * imgaussfilt(randn(rows,cols), 4);
    dy = jitterAmt * imgaussfilt(randn(rows,cols), 4);
    gx2 = clamp01mat((gx + dx) / cols) * cols;
    gy2 = clamp01mat((gy + dy) / rows) * rows;
    lines = interp2(gx, gy, lines, gx2, gy2, 'linear', 1);

    % 3. PRESSURE VARIATION: multiply by slow noise field so some lines
    %    are darker and some are lighter, like varying hand pressure
    pressure = 0.6 + 0.4 * imgaussfilt(rand(rows,cols), max(8, cols*0.05));
    lines = clamp01mat(lines .* pressure);

    % 4. SHADING LAYER: dark areas get hatching built from gradient direction
    Ix = imfilter(gray, fspecial('sobel')', 'replicate');
    Iy = imfilter(gray, fspecial('sobel'),  'replicate');
    gradMag = clamp01mat(sqrt(Ix.^2 + Iy.^2) * 2.5);
    darkMask = clamp01mat(1 - gray);
    hatch = darkMask .* (gradMag * 0.5 + 0.5);   % shading in dark regions

    % Make hatching rough — add noise to its intensity
    hatchNoise = imgaussfilt(rand(rows,cols), 2) * 0.3;
    hatch = clamp01mat(hatch .* (0.7 + hatchNoise));

    % 5. SMUDGING: blur the shading slightly (finger smudging effect)
    smudgeSig = max(0.5, intensity * 1.5);
    hatch = imgaussfilt(hatch, smudgeSig);

    % 6. COMBINE lines + shading
    sketch = clamp01mat(lines - hatch * intensity * 0.55);

    % 7. Contrast stretch using percentiles (not imadjust — more natural)
    lo = prctile(sketch(:), 3);
    hi = prctile(sketch(:), 96);
    sketch = clamp01mat((sketch - lo) / max(0.01, hi - lo));

    % 8. Gamma lift — pencil on paper is never pure black, always slightly grey
    sketch = sketch .^ 0.82;

    % 9. UNEVEN PAPER: slight large-scale brightness variation across the page
    %    (like slightly worn or textured paper)
    paperWarp = 1 - 0.06 * imgaussfilt(rand(rows,cols), max(20, rows*0.12));
    sketch = clamp01mat(sketch .* paperWarp);

    % 10. Warm cream tint — unmistakably pencil on off-white paper
    R = clamp01mat(sketch * 0.95 + 0.05);
    G = clamp01mat(sketch * 0.92 + 0.04);
    B = clamp01mat(sketch * 0.80 + 0.01);

    out = uint8(clampU8(cat(3, R, G, B) * 255));
end

function icon = makeToolIcon(R, style, accentColor)
% Returns an RGBA icon appropriate for each painting style
    switch style
        case 'sketch'
            icon = iconPencil(R);
        case 'watercolor'
            icon = iconWaterBrush(R, [0.35 0.70 0.95]);
        case 'impressionist'
            icon = iconFanBrush(R, [0.85 0.35 0.20]);
        otherwise  % oil
            icon = iconFlatBrush(R, accentColor);
    end
end

function icon = iconPencil(R)
% Pencil: thin yellow hexagonal body tapering to a dark point
    W = R*3;  H = R*9;
    icon = zeros(H, W, 4);
    cx = W/2;
    % Body: yellow rectangle
    bodyH = round(H*0.65);
    x1=1; x2=W; y1=1; y2=bodyH;
    icon(y1:y2, x1:x2, 1) = 0.98;  % R
    icon(y1:y2, x1:x2, 2) = 0.82;  % G
    icon(y1:y2, x1:x2, 3) = 0.10;  % B
    icon(y1:y2, x1:x2, 4) = 1.0;
    % Wood cone: beige triangle below body
    coneY1 = bodyH+1; coneY2 = round(H*0.85);
    for y = coneY1:coneY2
        frac = (y-coneY1)/(coneY2-coneY1+1);
        hw = max(0, (1-frac)*W/2);
        lx = max(1,round(cx-hw)); rx = min(W,round(cx+hw));
        icon(y, lx:rx, 1) = 0.85; icon(y, lx:rx, 2) = 0.65;
        icon(y, lx:rx, 3) = 0.40; icon(y, lx:rx, 4) = 1.0;
    end
    % Graphite tip: dark point
    tipY1 = round(H*0.85)+1; tipY2 = H;
    for y = tipY1:tipY2
        frac = (y-tipY1)/(tipY2-tipY1+1);
        hw = max(0, (1-frac)*W/2*0.35);
        lx = max(1,round(cx-hw)); rx = min(W,round(cx+hw));
        if lx<=rx
            icon(y, lx:rx, 1) = 0.15; icon(y, lx:rx, 2) = 0.12;
            icon(y, lx:rx, 3) = 0.10; icon(y, lx:rx, 4) = 1.0;
        end
    end
    % Eraser pink band at top
    icon(1:round(R*0.8), :, 1) = 0.95; icon(1:round(R*0.8), :, 2) = 0.60;
    icon(1:round(R*0.8), :, 3) = 0.65; icon(1:round(R*0.8), :, 4) = 1.0;
end

function icon = iconFlatBrush(R, col)
% Flat oil brush: wide rectangular bristle head + long wooden handle
    bW = R*3;  bH = R*2;   % bristle block
    hW = max(3,round(R*0.6)); hH = R*7;  % handle
    W = bW;    H = bH+hH;
    icon = zeros(H, W, 4);
    cx = W/2;
    % Bristles: coloured flat block
    for ch=1:3, icon(1:bH, 1:bW, ch) = col(ch); end
    icon(1:bH, 1:bW, 4) = 1.0;
    % Dark ferrule band
    fH = max(2,round(R*0.4));
    icon(bH+1:bH+fH, max(1,round(cx-hW)):min(W,round(cx+hW)), 1) = 0.25;
    icon(bH+1:bH+fH, max(1,round(cx-hW)):min(W,round(cx+hW)), 2) = 0.25;
    icon(bH+1:bH+fH, max(1,round(cx-hW)):min(W,round(cx+hW)), 3) = 0.28;
    icon(bH+1:bH+fH, max(1,round(cx-hW)):min(W,round(cx+hW)), 4) = 1.0;
    % Wooden handle
    lx=max(1,round(cx-hW)); rx=min(W,round(cx+hW));
    icon(bH+fH+1:H, lx:rx, 1) = 0.75; icon(bH+fH+1:H, lx:rx, 2) = 0.50;
    icon(bH+fH+1:H, lx:rx, 3) = 0.20; icon(bH+fH+1:H, lx:rx, 4) = 1.0;
end

function icon = iconWaterBrush(R, col)
% Round watercolour brush: pointed tapered bristle tip + thin handle
    W = R*2+2;  H = R*9;
    icon = zeros(H, W, 4);
    cx = (W+1)/2;
    % Round bristle head — fat at top, tapers to a fine point
    headH = round(H*0.45);
    for y = 1:headH
        frac = y/headH;
        % Widen then taper (round brush profile)
        if frac < 0.4
            hw = frac/0.4 * R;
        else
            hw = (1-frac)/0.6 * R * 0.95;
        end
        lx=max(1,round(cx-hw)); rx=min(W,round(cx+hw));
        if lx<=rx
            for ch=1:3, icon(y,lx:rx,ch)=col(ch); end
            icon(y,lx:rx,4)=1.0;
        end
    end
    % Ferrule
    fH=max(2,round(R*0.35)); fw=max(2,round(R*0.55));
    lx=max(1,round(cx-fw)); rx=min(W,round(cx+fw));
    icon(headH+1:headH+fH,lx:rx,1)=0.55; icon(headH+1:headH+fH,lx:rx,2)=0.55;
    icon(headH+1:headH+fH,lx:rx,3)=0.58; icon(headH+1:headH+fH,lx:rx,4)=1.0;
    % Handle
    hw2=max(1,round(R*0.25));
    lx=max(1,round(cx-hw2)); rx=min(W,round(cx+hw2));
    icon(headH+fH+1:H,lx:rx,1)=0.20; icon(headH+fH+1:H,lx:rx,2)=0.55;
    icon(headH+fH+1:H,lx:rx,3)=0.80; icon(headH+fH+1:H,lx:rx,4)=1.0;
end

function icon = iconFanBrush(R, col)
% Fan/palette knife brush for impressionist: splayed bristles at top
    W = R*4;  H = R*9;
    icon = zeros(H, W, 4);
    cx = (W+1)/2;
    fanH = round(H*0.30);
    % Splayed fan: multiple thin lines fanning outward from ferrule point
    nTines = 7;
    for t = 1:nTines
        frac = (t-1)/(nTines-1);  % 0..1
        % angle spreads from -40° to +40°
        tipX = cx + (frac-0.5)*W*0.85;
        tipY = 1;
        baseX = cx + (frac-0.5)*R*0.4;
        baseY = fanH;
        % Draw line between tip and base
        nPts = fanH;
        xs = round(linspace(tipX, baseX, nPts));
        ys = round(linspace(tipY, baseY, nPts));
        for p2=1:nPts
            xi=xs(p2); yi=ys(p2);
            if xi>=1&&xi<=W&&yi>=1&&yi<=H
                icon(yi,xi,1)=col(1); icon(yi,xi,2)=col(2);
                icon(yi,xi,3)=col(3); icon(yi,xi,4)=1.0;
                % Thicken slightly
                if xi>1
                    icon(yi,xi-1,1)=col(1)*0.8;icon(yi,xi-1,2)=col(2)*0.8;
                    icon(yi,xi-1,3)=col(3)*0.8;icon(yi,xi-1,4)=0.7;
                end
            end
        end
    end
    % Ferrule
    fH=max(2,round(R*0.4)); fw=max(2,round(R*0.55));
    lx=max(1,round(cx-fw)); rx=min(W,round(cx+fw));
    icon(fanH:fanH+fH,lx:rx,1)=0.55;icon(fanH:fanH+fH,lx:rx,2)=0.55;
    icon(fanH:fanH+fH,lx:rx,3)=0.55;icon(fanH:fanH+fH,lx:rx,4)=1.0;
    % Handle
    hw2=max(1,round(R*0.3));
    lx=max(1,round(cx-hw2)); rx=min(W,round(cx+hw2));
    icon(fanH+fH+1:H,lx:rx,1)=0.60;icon(fanH+fH+1:H,lx:rx,2)=0.35;
    icon(fanH+fH+1:H,lx:rx,3)=0.10;icon(fanH+fH+1:H,lx:rx,4)=1.0;
end

function out = overlayBrush(canvas, icon, tipX, tipY)
% Composite brush icon onto canvas at given tip position
    out = canvas;
    [ih, iw, ~] = size(icon);
    % Offset so bristle tip aligns with tipX/tipY
    ox = tipX - round(iw/2);
    oy = tipY - round(ih*0.35);

    x1i=1; x2i=iw; y1i=1; y2i=ih;
    x1c=ox; x2c=ox+iw-1; y1c=oy; y2c=oy+ih-1;

    % Clamp to canvas bounds
    if x1c<1,   x1i=x1i+(1-x1c);  x1c=1;  end
    if y1c<1,   y1i=y1i+(1-y1c);  y1c=1;  end
    [cr,cc,~] = size(canvas);
    if x2c>cc,  x2i=x2i-(x2c-cc); x2c=cc; end
    if y2c>cr,  y2i=y2i-(y2c-cr); y2c=cr; end
    if x1i>x2i || y1i>y2i || x1c>x2c || y1c>y2c, return; end

    alpha = icon(y1i:y2i, x1i:x2i, 4);
    for ch=1:3
        layer = double(out(y1c:y2c, x1c:x2c, ch))/255;
        fg    = icon(y1i:y2i, x1i:x2i, ch);
        layer = layer.*(1-alpha) + fg.*alpha;
        out(y1c:y2c, x1c:x2c, ch) = uint8(min(255,max(0,layer*255)));
    end
end

function canvas = paintBristleStroke(canvas, sx, sy, ang, len, wid, col, rows, cols)
% Fast vectorised bristle stroke — no inner loops, one meshgrid, one blend pass.
    halfL = len/2;  halfW = wid/2;
    cosA  = cos(ang); sinA = sin(ang);

    % Tight bounding box
    hw = ceil(abs(halfL*cosA) + abs(halfW*sinA)) + 2;
    hh = ceil(abs(halfL*sinA) + abs(halfW*cosA)) + 2;
    x1 = max(1,sx-hw); x2 = min(cols,sx+hw);
    y1 = max(1,sy-hh); y2 = min(rows,sy+hh);
    if x1>=x2 || y1>=y2, return; end

    [gx_l, gy_l] = meshgrid(x1:x2, y1:y2);
    dx =  (gx_l-sx)*cosA + (gy_l-sy)*sinA;   % along stroke
    dy = -(gx_l-sx)*sinA + (gy_l-sy)*cosA;   % across stroke

    tN = dx/halfL;   % -1..1 along length
    wN = dy/halfW;   % -1..1 across width

    % 1. Flat body: inside stroke rectangle
    inBox = (abs(tN) < 1.0) & (abs(wN) < 1.0);

    % 2. End taper: feather only the last 20% of each end
    endT = ones(size(tN));
    outer = abs(tN) > 0.80;
    endT(outer) = max(0, 1 - ((abs(tN(outer))-0.80)/0.20).^1.2);

    % 3. Side softness: sharp but slightly soft edge across width
    sideT = max(0, 1 - max(0, abs(wN)-0.75)/0.25 );

    % 4. Bristle tracks: cosine ripple across width — parallel lines
    %    frequency = ~6 tracks across the stroke width
    bristleTex = 0.72 + 0.28 * cos(dy * (6/max(halfW,1)) * pi);

    % 5. Ragged side edge: high-freq sine along length modulates the side cutoff
    fray = 1 - 0.20 * abs(sin(dx * (10/max(halfL,1)) * pi)) ...
               .* max(0, (abs(wN)-0.55)/0.45);
    fray = max(0, fray);

    % 6. Paint load: fades slightly toward stroke end (brush running dry)
    load = 0.70 + 0.30 * max(0, 1 - max(0,(tN+1)/2));

    % Combine
    alpha = inBox .* endT .* sideT .* bristleTex .* fray .* load;
    alpha = min(0.90, max(0, alpha));
    alpha(alpha < 0.05) = 0;

    if ~any(alpha(:)), return; end

    for ch = 1:3
        layer = double(canvas(y1:y2,x1:x2,ch))/255;
        layer = layer.*(1-alpha) + col(ch).*alpha;
        canvas(y1:y2,x1:x2,ch) = uint8(min(255,max(0,layer*255)));
    end
end

function alpha = buildStrokeMask(sx, sy, ang, len, wid, rows, cols)
% Returns a single-precision alpha mask the same size as the canvas
% for a stroke at (sx,sy) with given angle/length/width.
    alpha = zeros(rows, cols, 'single');
    if len < 1 || wid < 1, return; end
    halfL = len/2;  halfW = wid/2;
    cosA  = cos(ang); sinA = sin(ang);
    hw = ceil(abs(halfL*cosA)+abs(halfW*sinA))+2;
    hh = ceil(abs(halfL*sinA)+abs(halfW*cosA))+2;
    x1=max(1,sx-hw); x2=min(cols,sx+hw);
    y1=max(1,sy-hh); y2=min(rows,sy+hh);
    if x1>=x2||y1>=y2, return; end
    [gx_l,gy_l] = meshgrid(x1:x2, y1:y2);
    dx =  (gx_l-sx)*cosA + (gy_l-sy)*sinA;
    dy = -(gx_l-sx)*sinA + (gy_l-sy)*cosA;
    tN = dx/halfL;  wN = dy/halfW;
    inBox = (abs(tN)<1.0) & (abs(wN)<1.0);
    endT  = ones(size(tN),'single');
    outer = abs(tN)>0.80;
    endT(outer) = single(max(0, 1-((abs(tN(outer))-0.80)/0.20).^1.2));
    sideT = single(max(0, 1-max(0,abs(wN)-0.75)/0.25));
    bristle = single(0.72 + 0.28*cos(dy*(6/max(halfW,1))*pi));
    fray  = single(1 - 0.20*abs(sin(dx*(10/max(halfL,1))*pi)) ...
                   .* max(0,(abs(wN)-0.55)/0.45));
    load  = single(0.72 + 0.28*max(0, 1-max(0,(tN+1)/2)));
    a = single(inBox) .* endT .* sideT .* bristle .* max(0,fray) .* load;
    a(a<0.05) = 0;
    alpha(y1:y2,x1:x2) = min(single(0.95), a);
end

%% ── Utility functions ────────────────────────────────────────────────────

function out = boostSat(img, factor)
    hsv = rgb2hsv(img);
    hsv(:,:,2) = min(1, hsv(:,:,2) * factor);
    out = im2uint8(hsv2rgb(hsv));
end

function out = boostSatD(imgD, factor)
% Same as boostSat but input/output is double [0..1]
    hsv = rgb2hsv(imgD);
    hsv(:,:,2) = min(1, hsv(:,:,2) * factor);
    out = hsv2rgb(hsv);
end

function out = clampU8(x)
    out = min(255, max(0, x));
end

function out = clamp01mat(x)
    out = min(1, max(0, x));
end

function img = limitSize(img, maxDim)
% Resize image so its longest side is <= maxDim
    [r,c,~] = size(img);
    longest = max(r,c);
    if longest > maxDim
        scale = maxDim / longest;
        img = imresize(img, scale);
    end
end

function s = styleLabel(key)
    map = struct('oil','Oil Paint','watercolor','Watercolor',...
                 'impressionist','Impressionist','sketch','Pencil Sketch');
    if isfield(map,key), s = map.(key); else, s = key; end
end

%% ═══════════════════════════════════════════════════════════════════════
%  UI WIDGET HELPERS
%% ═══════════════════════════════════════════════════════════════════════

function btn = makeBtn(parent,C,label,pos,cb)
    btn = uicontrol(parent,'Style','pushbutton','String',label,...
        'FontName','Helvetica','FontSize',10,...
        'ForegroundColor',C.text,'BackgroundColor',C.btnFace,...
        'HorizontalAlignment','left',...
        'Units','normalized','Position',pos,'Callback',cb);
end

function setBtnActive(btn,C,on)
    if on
        set(btn,'BackgroundColor',C.accent,'ForegroundColor',[0.05 0.05 0.05],...
            'FontWeight','bold');
    else
        set(btn,'BackgroundColor',C.btnFace,'ForegroundColor',C.text,...
            'FontWeight','normal');
    end
end

function makeSectionLabel(parent,C,txt,y)
    uicontrol(parent,'Style','text','String',txt,...
        'FontName','Helvetica','FontSize',8,'FontWeight','bold',...
        'ForegroundColor',C.subtext,'BackgroundColor',get(parent,'BackgroundColor'),...
        'HorizontalAlignment','left','Units','normalized','Position',[0.06 y 0.88 0.032]);
end

function lbl = makeStatRow(parent,C,key,val,y)
    uicontrol(parent,'Style','text','String',key,...
        'FontName','Helvetica','FontSize',9,'ForegroundColor',C.subtext,...
        'BackgroundColor',get(parent,'BackgroundColor'),'HorizontalAlignment','left',...
        'Units','normalized','Position',[0.06 y 0.44 0.20]);
    lbl = uicontrol(parent,'Style','text','String',val,...
        'FontName','Helvetica','FontSize',9,'FontWeight','bold',...
        'ForegroundColor',C.text,'BackgroundColor',get(parent,'BackgroundColor'),...
        'HorizontalAlignment','right','Units','normalized','Position',[0.50 y 0.44 0.20]);
end

function ax = makeCanvas(parent,pos,titleStr,C)
    ax = axes(parent,'Units','normalized','Position',pos,...
        'Color',[0.10 0.10 0.12],'XTick',[],'YTick',[],...
        'XColor',C.panel,'YColor',C.panel,'Box','on','LineWidth',1.5);
    
end

function showPlaceholder(ax,C,txt)
    cla(ax); set(ax,'Color',[0.10 0.10 0.12],'XTick',[],'YTick',[]);
    text(0.5,0.5,txt,'Parent',ax,'FontSize',11,...
        'HorizontalAlignment','center','Units','normalized',...
        'Color',C.subtext,'FontName','Helvetica');
end

function divider(parent,C,y)
    uipanel(parent,'BackgroundColor',[0.25 0.25 0.30],...
        'BorderType','none','Units','normalized','Position',[0.05 y 0.90 0.003]);
end
