const languageConfig = {
    en: {
        ei: ['Extraverted', 'Introverted'],
        ns: ['Intuitive', 'Observant'],
        tf: ['Thinking', 'Feeling'],
        jp: ['Judging', 'Prospecting'],
        at: ['Assertive', 'Turbulent'],
        linkPrefix: '',
        linkSuffix: 'personality',
        linkBriefText: 'View More',
        linkDetailedText: 'View Detailed Personality Analysis',

    },
    zh: {
        ei: ['外向', '内向'],
        ns: ['有远见', '现实'],
        tf: ['理性分析', '感受'],
        jp: ['评判', '展望'],
        at: ['坚决', '起伏不定'],
        linkPrefix: 'ch/',
        linkSuffix: '人格',
        linkBriefText: '查看更多',
        linkDetailedText: '查看性格剖析',
    }
};
const baseUrl = 'https://www.16personalities.com';
const imagesHostUrl = 'https://cdn.jsdelivr.net/gh/baobaodz/picx-images-hosting@master/hexo-mbti';

function getLocalizedContent(language, content) {
    const lang = language || 'zh';

    if (typeof content === 'object' && content.hasOwnProperty(lang)) {
        return content[lang];
    } else if (typeof content === 'string') {
        const key = content;
        if (languageConfig[lang] && languageConfig[lang][key]) {
            return languageConfig[lang][key];
        }
    }
    return content;
}

function getMBTIDimensions(config) {
    const lang = config.language || 'zh';
    const data = config.data || {};
    return [
        { id: 'ei', label: languageConfig[lang].ei, value: data['E-I'] || data[languageConfig[lang].ei.join('-')], color: config.color[0] },
        { id: 'ns', label: languageConfig[lang].ns, value: data['N-S'] || data[languageConfig[lang].ns.join('-')], color: config.color[1] },
        { id: 'tf', label: languageConfig[lang].tf, value: data['T-F'] || data[languageConfig[lang].tf.join('-')], color: config.color[2] },
        { id: 'jp', label: languageConfig[lang].jp, value: data['J-P'] || data[languageConfig[lang].jp.join('-')], color: config.color[3] },
        { id: 'at', label: languageConfig[lang].at, value: data['A-T'] || data[languageConfig[lang].at.join('-')], color: config.color[4] },
    ];
}

function calculatePersonalityType(config, dimensions) {
    const type = dimensions
        .slice(0, 4)
        .map(d => d.id[getDominantTraitIndex(d.value[1])].toUpperCase())
        .join('');
    const personalityType = personalityTypes.find(p => p.type === type);

    if (!personalityType) {
        return { type, name: '未知类型', desc: '' };
    }

    let result = {
        type,
        name: getLocalizedContent(config.language, personalityType.name),
        desc: getLocalizedContent(config.language, personalityType.desc),
    };
    result = {
        ...result,
        avatar: `${imagesHostUrl}/${result.type.toLowerCase()}-${personalityType.name.en.toLowerCase()}-s3-v1-${config.gender}.png?t=${Date.now()}`,
    }

    if (dimensions.length > 4) {
        const atDimension = dimensions[4].value[0] < 50 ? 'A' : 'T';
        result.type += '-' + atDimension;
    }
    return result;
};

function getDominantTraitIndex(value) {
    return value > 50 ? 1 : 0;
}

function getMoreInfoLink(language, personalityType) {
    return `${baseUrl}/${getLocalizedContent(language, 'linkPrefix')}${personalityType.type.slice(0,4).toLowerCase()}-${getLocalizedContent(language, 'linkSuffix')}`;

}
const cache = new Map();

function fetchWithCache(url, responseType = 'json') {
    if (cache.has(url)) {
        return Promise.resolve(cache.get(url));
    }

    return fetch(url)
        .then(response => {
            if (responseType === 'blob') {
                return response.blob();
            } else {
                return response.json();
            }
        })
        .then(data => {
            cache.set(url, data);
            return data;
        });
}

function debounce(func, delay) {
    let timer;
    return function(...args) {
        clearTimeout(timer);
        timer = setTimeout(() => func.apply(this, args), delay);
    };
}

function throttle(func, limit) {
    let inThrottle;
    return function(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}