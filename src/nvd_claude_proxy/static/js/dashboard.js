/**
 * nvd-claude-proxy Dashboard v1.1.0
 * Minimalist SPA logic with Fascinating "Official-Grade" Enhancements
 */

const state = {
    activeTab: 'sessions',
    sessions: [],
    models: {
        static_mappings: {},
        dynamic_mappings: [],
        available_nvidia_models: []
    },
    transformers: [],
    loading: true,
    ws: null,
    monitor: {
        openai: "",
        anthropic: "",
        fixes: []
    }
};

const API_BASE = '/api/dashboard';

async function fetchData(endpoint) {
    const res = await fetch(`${API_BASE}${endpoint}`);
    if (!res.ok) throw new Error(`API error: ${res.status}`);
    return await res.json();
}

async function postData(endpoint, data) {
    const res = await fetch(`${API_BASE}${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });
    if (!res.ok) throw new Error(`API error: ${res.status}`);
    return await res.json();
}

function render() {
    const contentArea = document.getElementById('content-area');
    if (!contentArea) return;

    if (state.loading) {
        contentArea.innerHTML = `
            <div class="flex items-center justify-center h-full">
                <div class="flex flex-col items-center">
                    <div class="relative w-16 h-16 mb-4">
                        <div class="absolute inset-0 rounded-full border-4 border-indigo-100"></div>
                        <div class="absolute inset-0 rounded-full border-4 border-t-indigo-600 animate-spin"></div>
                    </div>
                    <p class="text-gray-400 font-bold uppercase tracking-widest text-[10px]">Loading ${state.activeTab}</p>
                </div>
            </div>`;
        return;
    }

    switch (state.activeTab) {
        case 'sessions':
            renderSessions(contentArea);
            break;
        case 'models':
            renderModels(contentArea);
            break;
        case 'marketplace':
            renderMarketplace(contentArea);
            break;
        case 'transformers':
            renderTransformers(contentArea);
            break;
        case 'monitor':
            renderMonitor(contentArea);
            break;
        default:
            contentArea.innerHTML = `<div class="p-8 text-center text-gray-500">Tab "${state.activeTab}" not implemented.</div>`;
    }
    
    // Update navigation styles
    document.querySelectorAll('.nav-btn').forEach(btn => {
        if (btn.dataset.tab === state.activeTab) {
            btn.classList.add('bg-indigo-600', 'text-white', 'shadow-lg', 'shadow-indigo-600/20');
            btn.classList.remove('text-gray-400', 'hover:bg-gray-800');
        } else {
            btn.classList.remove('bg-indigo-600', 'text-white', 'shadow-lg', 'shadow-indigo-600/20');
            btn.classList.add('text-gray-400', 'hover:bg-gray-800');
        }
    });
    
    if (window.lucide) {
        lucide.createIcons();
    }
}

function renderSessions(container) {
    container.innerHTML = `
        <div class="mb-8 flex justify-between items-center">
            <div>
                <h2 class="text-2xl font-bold text-gray-900">Active Sessions</h2>
                <p class="text-sm text-gray-500 italic">History of unique proxy consumers identified by API key.</p>
            </div>
            <button onclick="refreshSessions()" class="flex items-center px-4 py-2 bg-white border border-gray-200 rounded-xl shadow-sm text-sm font-bold text-gray-600 hover:bg-gray-50 transition">
                <i data-lucide="rotate-cw" class="w-4 h-4 mr-2"></i> Refresh
            </button>
        </div>
        <div class="bg-white shadow-xl shadow-gray-200/50 rounded-2xl border border-gray-100 overflow-hidden">
            <table class="min-w-full divide-y divide-gray-100">
                <thead class="bg-gray-50/50">
                    <tr>
                        <th class="px-6 py-4 text-left text-[10px] font-black text-gray-400 uppercase tracking-widest">Identity</th>
                        <th class="px-6 py-4 text-left text-[10px] font-black text-gray-400 uppercase tracking-widest">Token Velocity</th>
                        <th class="px-6 py-4 text-left text-[10px] font-black text-gray-400 uppercase tracking-widest">Health</th>
                        <th class="px-6 py-4 text-left text-[10px] font-black text-gray-400 uppercase tracking-widest">Last Activity</th>
                        <th class="px-6 py-4 text-right text-[10px] font-black text-gray-400 uppercase tracking-widest">Actions</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-100">
                    ${state.sessions.length === 0 ? `
                        <tr><td colspan="5" class="px-6 py-16 text-center text-gray-400 italic font-medium">Zero activity detected on the wire.</td></tr>
                    ` : state.sessions.map(s => `
                        <tr class="hover:bg-indigo-50/30 transition-colors group">
                            <td class="px-6 py-4">
                                <div class="flex items-center">
                                    <div class="w-10 h-10 rounded-full bg-gradient-to-br from-indigo-100 to-white flex items-center justify-center mr-4 border border-indigo-50 text-indigo-600 font-black">
                                        ${(s.friendly_name || 'U')[0].toUpperCase()}
                                    </div>
                                    <div class="flex flex-col">
                                        <span class="text-sm font-bold text-gray-900 group-hover:text-indigo-600 transition-colors">${s.friendly_name || 'Unnamed Consumer'}</span>
                                        <span class="text-[10px] font-mono text-gray-400 font-semibold tracking-tighter">API-KEY: ${s.api_key.substring(0, 16)}...</span>
                                    </div>
                                </div>
                            </td>
                            <td class="px-6 py-4">
                                <div class="flex items-center space-x-4">
                                    <div>
                                        <p class="text-[9px] uppercase text-gray-400 font-black tracking-tighter mb-0.5">Total Emitted</p>
                                        <p class="font-mono text-sm font-bold text-gray-700">${s.tokens_used.toLocaleString()}</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-6 py-4">
                                <div class="flex items-center">
                                    <span class="w-1.5 h-1.5 rounded-full bg-green-500 mr-2 shadow-sm shadow-green-500/50"></span>
                                    <span class="text-[10px] font-black text-green-600 uppercase tracking-widest">Operational</span>
                                </div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-xs font-medium text-gray-500">
                                ${new Date(s.last_active).toLocaleString()}
                            </td>
                            <td class="px-6 py-4 text-right">
                                <button onclick="editFriendlyName('${s.api_key}', '${s.friendly_name || ''}')" class="p-2 text-gray-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition">
                                    <i data-lucide="edit-2" class="w-4 h-4"></i>
                                </button>
                            </td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>
        </div>
    `;
}

function renderModels(container) {
    container.innerHTML = `
        <div class="mb-8">
            <h2 class="text-2xl font-bold text-gray-900">Traffic Routing</h2>
            <p class="text-sm text-gray-500 italic font-medium">Intercept Anthropic aliases and steer them toward specific NVIDIA NIM endpoints.</p>
        </div>
        
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <!-- Dynamic Overrides -->
            <div class="bg-white shadow-xl shadow-gray-200/50 rounded-2xl border border-gray-100 p-8">
                <div class="flex justify-between items-center mb-8">
                    <h3 class="text-sm font-black text-gray-400 uppercase tracking-widest flex items-center">
                        <i data-lucide="repeat" class="w-4 h-4 mr-2 text-indigo-400"></i>
                        Dynamic Hot-Swaps
                    </h3>
                    <button onclick="addMapping()" class="inline-flex items-center px-4 py-1.5 bg-indigo-600 text-white rounded-xl text-xs font-black uppercase tracking-widest hover:bg-indigo-700 transition shadow-lg shadow-indigo-600/20">
                        <i data-lucide="plus" class="w-3.5 h-3.5 mr-1.5"></i> Intercept
                    </button>
                </div>
                <div class="space-y-4">
                    ${state.models.dynamic_mappings.length === 0 ? `
                        <div class="py-12 flex flex-col items-center justify-center text-gray-300 border-2 border-dashed border-gray-100 rounded-2xl">
                             <i data-lucide="ghost" class="w-8 h-8 mb-2"></i>
                             <p class="text-xs font-bold uppercase tracking-widest">No active interceptions</p>
                        </div>
                    ` : state.models.dynamic_mappings.map(m => `
                        <div class="flex items-center justify-between p-4 bg-gray-50/50 rounded-2xl border border-gray-100 group hover:border-indigo-200 transition-colors">
                            <div class="flex items-center">
                                <div class="w-8 h-8 bg-indigo-100 rounded-lg flex items-center justify-center mr-4">
                                    <i data-lucide="arrow-right-left" class="w-4 h-4 text-indigo-600"></i>
                                </div>
                                <div>
                                    <p class="font-mono text-[10px] font-black text-gray-400 uppercase tracking-tighter">Claude Alias</p>
                                    <p class="font-mono text-sm font-black text-indigo-600">${m.anthropic_model}</p>
                                </div>
                                <i data-lucide="chevron-right" class="mx-6 text-gray-300 w-4 h-4"></i>
                                <div>
                                    <p class="font-mono text-[10px] font-black text-gray-400 uppercase tracking-tighter">NVIDIA Target</p>
                                    <p class="font-mono text-sm font-bold text-gray-700">${m.nvd_model}</p>
                                </div>
                            </div>
                            <button onclick="editMapping('${m.anthropic_model}', '${m.nvd_model}')" class="opacity-0 group-hover:opacity-100 transition-opacity p-2 text-gray-300 hover:text-indigo-600 hover:bg-white rounded-xl shadow-sm">
                                <i data-lucide="settings" class="w-4 h-4"></i>
                            </button>
                        </div>
                    `).join('')}
                </div>
            </div>

            <!-- Static Registry -->
            <div class="bg-white shadow-xl shadow-gray-200/50 rounded-2xl border border-gray-100 p-8 flex flex-col">
                <h3 class="text-sm font-black text-gray-400 uppercase tracking-widest mb-8 flex items-center">
                    <i data-lucide="database" class="w-4 h-4 mr-2 text-gray-300"></i>
                    Static Registry (Boot)
                </h3>
                <div class="flex-grow space-y-3 overflow-y-auto max-h-[400px] pr-2 custom-scrollbar">
                    ${Object.entries(state.models.static_mappings).map(([alias, target]) => `
                        <div class="flex items-center justify-between p-3 rounded-xl border border-transparent hover:border-gray-100 hover:bg-gray-50/50 transition-all">
                            <span class="font-mono font-black text-gray-600 text-xs">${alias}</span>
                            <div class="flex-grow border-b border-dotted border-gray-200 mx-4 h-2"></div>
                            <span class="font-mono text-[10px] font-bold text-gray-400 bg-gray-100 px-2 py-0.5 rounded-lg">${target.split('/').pop()}</span>
                        </div>
                    `).join('')}
                </div>
                <div class="mt-8 pt-4 border-t border-gray-50 flex items-center justify-between">
                    <span class="text-[9px] font-black text-gray-400 uppercase tracking-widest">Source: models.yaml</span>
                    <span class="text-[9px] font-bold text-indigo-400 bg-indigo-50 px-2 py-0.5 rounded-full uppercase">Official Registry</span>
                </div>
            </div>
        </div>
    `;
}

function renderMarketplace(container) {
    container.innerHTML = `
        <div class="mb-8">
            <h2 class="text-2xl font-bold text-gray-900">NVIDIA NIM Marketplace</h2>
            <p class="text-sm text-gray-500 italic font-medium">Browse and attach free, high-performance NIM models directly to your Claude environment.</p>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            ${state.models.available_nvidia_models.length === 0 ? `
                <div class="col-span-full py-20 text-center text-gray-400 font-bold uppercase tracking-widest text-xs italic">
                    <i data-lucide="refresh-cw" class="w-8 h-8 mx-auto mb-4 animate-spin opacity-20"></i>
                    Synchronizing with NVIDIA Global Registry...
                </div>
            ` : state.models.available_nvidia_models.map(m => `
                <div class="bg-white rounded-3xl border border-gray-100 p-6 shadow-sm hover:shadow-xl hover:shadow-indigo-600/5 hover:-translate-y-1 transition-all duration-300 flex flex-col group relative overflow-hidden">
                    <div class="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-100 transition-opacity">
                        <i data-lucide="box" class="w-20 h-20 -mr-6 -mt-6 text-indigo-600"></i>
                    </div>
                    <div class="flex items-center mb-6">
                        <div class="w-12 h-12 bg-gray-900 rounded-2xl flex items-center justify-center mr-4 shadow-lg shadow-black/10">
                            <img src="https://www.nvidia.com/favicon.ico" class="w-6 h-6 grayscale invert brightness-200" alt="NVIDIA">
                        </div>
                        <div class="flex flex-col min-w-0">
                            <h4 class="font-black text-gray-900 text-sm truncate uppercase tracking-tighter leading-none">${m.id.split('/').pop()}</h4>
                            <span class="text-[9px] font-black text-indigo-500 uppercase tracking-widest mt-1">${m.owned_by}</span>
                        </div>
                    </div>
                    <div class="flex-grow space-y-3 mb-8">
                        <div class="flex items-center text-[10px] font-bold text-gray-400">
                             <i data-lucide="cpu" class="w-3 h-3 mr-2"></i> NVIDIA OPTIMIZED
                        </div>
                        <div class="flex items-center text-[10px] font-bold text-gray-400">
                             <i data-lucide="shield" class="w-3 h-3 mr-2"></i> ENTERPRISE READY
                        </div>
                        <div class="flex items-center text-[10px] font-bold text-gray-400">
                             <i data-lucide="zap" class="w-3 h-3 mr-2"></i> SUB-SECOND LATENCY
                        </div>
                    </div>
                    <button onclick="window.attachModelFromMarket('${m.id}')" 
                            class="w-full py-3 bg-gray-50 text-gray-900 rounded-2xl text-[11px] font-black uppercase tracking-widest hover:bg-indigo-600 hover:text-white transition-all shadow-sm group-hover:shadow-indigo-600/20">
                        Attach to Claude
                    </button>
                </div>
            `).join('')}
        </div>
    `;
}

function renderTransformers(container) {
    container.innerHTML = `
        <div class="mb-8">
            <h2 class="text-2xl font-bold text-gray-900">Transformer Policies</h2>
            <p class="text-sm text-gray-500 italic font-medium">Activate real-time behavioral modifiers and "Official-Grade" fixes.</p>
        </div>
        <div class="bg-white shadow-xl shadow-gray-200/50 rounded-3xl border border-gray-100 overflow-hidden max-w-2xl">
            <div class="divide-y divide-gray-50">
                ${state.transformers.length === 0 ? `
                    <div class="p-16 text-center">
                        <i data-lucide="settings-2" class="w-12 h-12 text-gray-100 mx-auto mb-4"></i>
                        <p class="text-gray-400 font-bold uppercase tracking-widest text-[10px]">No policy overrides detected</p>
                    </div>
                ` : state.transformers.map(t => `
                    <div class="p-6 flex items-center justify-between hover:bg-indigo-50/20 transition-colors">
                        <div class="flex items-center">
                            <div class="w-12 h-12 ${t.enabled ? 'bg-indigo-600 text-white' : 'bg-gray-100 text-gray-400'} rounded-2xl flex items-center justify-center mr-5 transition-colors">
                                <i data-lucide="zap" class="w-5 h-5"></i>
                            </div>
                            <div>
                                <p class="font-black text-gray-900 text-sm tracking-tighter">${t.transformer_name}</p>
                                <div class="flex items-center mt-1">
                                    <span class="text-[9px] font-black uppercase tracking-widest px-2 py-0.5 rounded-full ${t.session_id ? 'bg-orange-100 text-orange-700' : 'bg-blue-100 text-blue-700'}">
                                        ${t.session_id ? 'Session Scope' : 'Global Baseline'}
                                    </span>
                                    ${t.session_id ? `<span class="text-[10px] font-mono text-gray-400 ml-3 font-bold">ID: ${t.session_id}</span>` : ''}
                                </div>
                            </div>
                        </div>
                        <button onclick="toggleTransformer(${t.id}, '${t.transformer_name}', ${t.enabled}, ${t.session_id})" 
                                class="relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none ${t.enabled ? 'bg-indigo-600' : 'bg-gray-200'}">
                            <span class="pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow-xl transition duration-200 ease-in-out ${t.enabled ? 'translate-x-5' : 'translate-x-0'}"></span>
                        </button>
                    </div>
                `).join('')}
            </div>
        </div>
    `;
}

function renderMonitor(container) {
    container.innerHTML = `
        <div class="flex flex-col h-full max-h-[calc(100vh-120px)]">
            <div class="mb-4 flex justify-between items-center">
                <div>
                    <h2 class="text-2xl font-bold text-gray-900">Live Traffic Monitor</h2>
                    <p class="text-sm text-gray-500 italic font-medium">Streaming OpenAI (Inbound) &rarr; Anthropic (Outbound) events.</p>
                </div>
                <div id="connection-status" class="flex items-center text-[10px] font-black uppercase tracking-widest text-gray-400">
                    <span class="w-2 h-2 rounded-full bg-gray-300 mr-2 animate-pulse"></span> Offline
                </div>
            </div>

            <!-- Fix Ticker -->
            <div class="bg-gray-900 text-indigo-100 px-6 py-2.5 rounded-2xl mb-6 overflow-hidden relative h-12 flex items-center border border-gray-800 shadow-2xl">
                <div class="absolute left-0 top-0 bottom-0 px-4 bg-indigo-600 flex items-center z-10 border-r border-indigo-700 shadow-xl">
                    <i data-lucide="shield-check" class="w-4 h-4 text-white mr-2"></i>
                    <span class="text-[10px] font-black uppercase tracking-widest">Protocol Fixer</span>
                </div>
                <div id="fix-ticker" class="whitespace-nowrap flex space-x-12 pl-40">
                    <span class="text-gray-600 font-bold uppercase tracking-widest text-[9px] italic">Monitoring for architectural anomalies...</span>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 flex-grow overflow-hidden min-h-0">
                <!-- OpenAI Window (In) -->
                <div class="bg-gray-950 rounded-3xl border border-gray-900 flex flex-col overflow-hidden shadow-2xl relative">
                    <div class="bg-gray-900/50 px-5 py-3 flex items-center justify-between border-b border-gray-900">
                        <span class="text-[10px] font-black text-gray-500 uppercase tracking-widest flex items-center">
                             <span class="w-1.5 h-1.5 bg-blue-500 rounded-full mr-2"></span> Upstream Payload
                        </span>
                        <button onclick="clearMonitor('openai')" class="text-gray-600 hover:text-white transition">
                            <i data-lucide="trash-2" class="w-3.5 h-3.5"></i>
                        </button>
                    </div>
                    <pre id="openai-window" class="flex-grow p-6 text-[11px] text-blue-400/80 overflow-y-auto font-mono leading-relaxed scroll-smooth custom-scrollbar bg-[radial-gradient(circle_at_top_right,_var(--tw-gradient-stops))] from-blue-900/10 via-transparent to-transparent">${state.monitor.openai || '// Waiting for upstream chunks...'}</pre>
                </div>

                <!-- Anthropic Window (Out) -->
                <div class="bg-gray-950 rounded-3xl border border-gray-900 flex flex-col overflow-hidden shadow-2xl relative">
                    <div class="bg-gray-900/50 px-5 py-3 flex items-center justify-between border-b border-gray-900">
                        <span class="text-[10px] font-black text-gray-500 uppercase tracking-widest flex items-center">
                             <span class="w-1.5 h-1.5 bg-green-500 rounded-full mr-2"></span> Client Response
                        </span>
                        <button onclick="clearMonitor('anthropic')" class="text-gray-600 hover:text-white transition">
                            <i data-lucide="trash-2" class="w-3.5 h-3.5"></i>
                        </button>
                    </div>
                    <div id="anthropic-window-container" class="flex-grow overflow-y-auto custom-scrollbar p-6 space-y-4 bg-[radial-gradient(circle_at_top_right,_var(--tw-gradient-stops))] from-green-900/10 via-transparent to-transparent">
                         <div id="anthropic-log-stream" class="font-mono text-[11px] text-green-400/80 leading-relaxed whitespace-pre-wrap"></div>
                    </div>
                </div>
            </div>
        </div>
        <style>
            .custom-scrollbar::-webkit-scrollbar { width: 4px; }
            .custom-scrollbar::-webkit-scrollbar-thumb { background: #1f2937; border-radius: 10px; }
            .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #374151; }
            
            .event-card {
                border-left: 2px solid #059669;
                padding-left: 1rem;
                margin-bottom: 1.5rem;
                animation: slideIn 0.3s ease-out;
            }
            .event-type {
                font-size: 9px;
                font-weight: 900;
                text-transform: uppercase;
                letter-spacing: 0.1em;
                color: #34d399;
                margin-bottom: 0.25rem;
            }
            @keyframes slideIn {
                from { opacity: 0; transform: translateX(10px); }
                to { opacity: 1; transform: translateX(0); }
            }
            .tool-pulse {
                animation: pulse-green 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
            }
            @keyframes pulse-green {
                0%, 100% { opacity: 1; }
                50% { opacity: .5; }
            }
        </style>
    `;
    
    initMonitorWS();
    if (window.lucide) lucide.createIcons();
}

function initMonitorWS() {
    if (state.ws && state.ws.readyState === WebSocket.OPEN) {
        updateConnectionStatus(true);
        return;
    }

    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = `${protocol}//${window.location.host}/ws/monitor`;
    
    console.log('Connecting to monitor WS:', wsUrl);
    state.ws = new WebSocket(wsUrl);

    state.ws.onopen = () => {
        console.log('Monitor WS Connected');
        updateConnectionStatus(true);
    };

    state.ws.onclose = () => {
        console.log('Monitor WS Disconnected');
        updateConnectionStatus(false);
        setTimeout(initMonitorWS, 5000);
    };

    state.ws.onmessage = (event) => {
        try {
            const data = JSON.parse(event.data);
            handleWSMessage(data);
        } catch (e) {
            console.error('Failed to parse WS message', e);
        }
    };
}

function updateConnectionStatus(connected) {
    const statusEl = document.getElementById('connection-status');
    if (!statusEl) return;
    
    if (connected) {
        statusEl.innerHTML = `<span class="w-2 h-2 rounded-full bg-green-500 mr-2 shadow-lg shadow-green-500/50"></span> Protocol Tunneled`;
        statusEl.classList.remove('text-gray-400');
        statusEl.classList.add('text-green-500');
    } else {
        statusEl.innerHTML = `<span class="w-2 h-2 rounded-full bg-red-500 mr-2 animate-pulse"></span> Link Severed`;
        statusEl.classList.remove('text-green-500');
        statusEl.classList.add('text-red-500');
    }
}

function handleWSMessage(msg) {
    const { type, payload, request_id } = msg;
    const shortId = request_id ? request_id.substring(0,8) : 'sys';
    
    if (type === 'openai_chunk') {
        const text = JSON.stringify(payload, null, 2);
        state.monitor.openai += `\n[${shortId}] ${text}`;
        const win = document.getElementById('openai-window');
        if (win) {
            win.textContent = state.monitor.openai;
            win.scrollTop = win.scrollHeight;
        }
    } else if (type === 'anthropic_event') {
        renderBeautifulAnthropicEvent(shortId, payload);
    } else if (type === 'transformer_fix') {
        const fixText = `${msg.fix_type}: ${JSON.stringify(payload)}`;
        addFixToTicker(fixText);
    } else if (type === 'error') {
        state.monitor.anthropic += `\n[ERROR] ${JSON.stringify(payload, null, 2)}`;
        const streamContainer = document.getElementById('anthropic-log-stream');
        if (streamContainer) {
             streamContainer.innerHTML += `<div class="text-red-500 font-bold">[${shortId}] ERROR: ${JSON.stringify(payload)}</div>`;
        }
    }
}

function renderBeautifulAnthropicEvent(reqId, event) {
    const streamContainer = document.getElementById('anthropic-log-stream');
    if (!streamContainer) return;

    let html = `<div class="event-card">`;
    html += `<div class="event-type">${event.event} <span class="text-gray-600 font-mono ml-2">[${reqId}]</span></div>`;

    const data = event.data;
    if (event.event === 'content_block_start' && data.content_block?.type === 'tool_use') {
        html += `<div class="bg-indigo-900/30 p-3 rounded-xl border border-indigo-500/30 flex items-center">
            <i data-lucide="box" class="w-4 h-4 text-indigo-400 mr-3 tool-pulse"></i>
            <div>
                <span class="text-indigo-300 font-black uppercase text-[10px]">Calling Tool:</span>
                <span class="text-white font-bold ml-2">${data.content_block.name}</span>
                <div class="text-[9px] text-indigo-400 font-mono mt-0.5">ID: ${data.content_block.id}</div>
            </div>
        </div>`;
    } else if (event.event === 'content_block_delta' && data.delta?.type === 'input_json_delta') {
        html += `<div class="font-mono text-indigo-300/80 bg-black/20 p-2 rounded-lg mt-1 italic">${data.delta.partial_json}</div>`;
    } else if (event.event === 'message_start') {
        html += `<div class="text-xs text-gray-500 font-bold uppercase tracking-tighter">Handshake established with ${data.message.model}</div>`;
    } else {
        html += `<div class="opacity-60 overflow-hidden truncate">${JSON.stringify(data)}</div>`;
    }
    
    html += `</div>`;
    streamContainer.innerHTML += html;
    
    const container = document.getElementById('anthropic-window-container');
    if (container) container.scrollTop = container.scrollHeight;
    
    if (window.lucide) lucide.createIcons();
}

function addFixToTicker(text) {
    const ticker = document.getElementById('fix-ticker');
    if (!ticker) return;

    if (state.monitor.fixes.length === 0) { ticker.innerHTML = ''; }
    state.monitor.fixes.push(text);
    if (state.monitor.fixes.length > 10) state.monitor.fixes.shift();

    const span = document.createElement('span');
    span.className = 'text-indigo-300 font-black uppercase tracking-tighter mr-12 text-[10px] flex items-center';
    span.innerHTML = `<i data-lucide="zap" class="w-3 h-3 text-yellow-400 mr-2"></i> FIXED: ${text}`;
    ticker.appendChild(span);
    ticker.scrollLeft = ticker.scrollWidth;
    if (window.lucide) lucide.createIcons();
}

window.clearMonitor = (type) => {
    state.monitor[type] = "";
    if (type === 'openai') {
        const win = document.getElementById('openai-window');
        if (win) win.textContent = "// Stream reset. Listening...";
    } else {
        const streamContainer = document.getElementById('anthropic-log-stream');
        if (streamContainer) streamContainer.innerHTML = "";
    }
};

window.refreshSessions = async () => {
    state.loading = true; render();
    try {
        state.sessions = await fetchData('/sessions');
    } catch(e) { console.error('Failed to fetch sessions'); }
    state.loading = false; render();
};

window.editFriendlyName = async (apiKey, current) => {
    const newName = prompt('Enter a recognizable name for this API key:', current);
    if (newName !== null) {
        try {
            await postData(`/sessions/${apiKey}/friendly_name`, { friendly_name: newName });
            window.refreshSessions();
        } catch(e) { alert('Failed to update name'); }
    }
};

window.attachModelFromMarket = async (nimId) => {
    const alias = prompt(`Enter a Claude alias for this NIM model (e.g. claude-3-7-custom):`, nimId.split('/').pop());
    if (alias) {
        try {
            await postData('/models/map', { anthropic_model: alias, nvd_model: nimId });
            alert(`✓ Model successfully attached as "${alias}"`);
            loadTab('models');
        } catch(e) { alert('Failed to attach model'); }
    }
};

window.editMapping = async (anthropicModel, currentNvd) => {
    const nvdModel = prompt(`Map "${anthropicModel}" to which NVIDIA model?`, currentNvd);
    if (nvdModel) {
        try {
            await postData('/models/map', { anthropic_model: anthropicModel, nvd_model: nvdModel });
            loadTab('models');
        } catch(e) { alert('Failed to update mapping'); }
    }
};

window.addMapping = async () => {
    const anthropicModel = prompt('Anthropic Model Name (e.g. claude-3-5-sonnet):');
    if (!anthropicModel) return;
    const nvdModel = prompt('Target NVIDIA NIM Identifier:');
    if (!nvdModel) return;
    try {
        await postData('/models/map', { anthropic_model: anthropicModel, nvd_model: nvdModel });
        loadTab('models');
    } catch(e) { alert('Failed to create mapping'); }
};

window.toggleTransformer = async (id, name, current, sessionId) => {
    try {
        await postData('/transformers/toggle', { 
            transformer_name: name, 
            enabled: !current,
            session_id: sessionId
        });
        loadTab('transformers');
    } catch(e) { alert('Failed to toggle transformer'); }
};

async function loadTab(tab) {
    state.activeTab = tab;
    state.loading = true;
    render();
    
    try {
        if (tab === 'sessions') {
            state.sessions = await fetchData('/sessions');
        } else if (tab === 'models' || tab === 'marketplace') {
            state.models = await fetchData('/models');
        } else if (tab === 'transformers') {
            state.transformers = await fetchData('/transformers');
        }
    } catch (err) {
        console.error('Failed to fetch data', err);
    }
    
    state.loading = false;
    render();
}

// Global Event Listeners
document.addEventListener('DOMContentLoaded', () => {
    document.addEventListener('click', e => {
        const btn = e.target.closest('.nav-btn');
        if (btn) {
            loadTab(btn.dataset.tab);
        }
    });
    loadTab('sessions');
    initMonitorWS();
});
