// src/components/Menu.tsx
import React, { useState, useEffect, useRef } from 'react';
import styles from './Menu.module.scss';
import { fetchNui } from '@utilities/utils';

export interface MenuItem {
	label: string;
	menu?: string;
	eventName?: string;
	isServer?: boolean;
	args?: any[];
	choices?: number[];  // now explicit number list
	// export
	export?: string;
	resourceName?: string;
}

interface MenuProps {
	items?: MenuItem[];
	menuKey?: string;
}

const Menu: React.FC<MenuProps> = ({ items = [], menuKey = 'main' }) => {
	const [selectedIndex, setSelectedIndex] = useState(0);
	const [choiceIdx, setChoiceIdx] = useState<Record<number, number>>({});
	const listRef = useRef<HTMLUListElement>(null);

	// Build displayItems (back at end)
	const backItem: MenuItem = { label: '← Back', menu: 'main' };
	const displayItems = menuKey === 'main' ? items : [...items, backItem];

	// on menu change: reset selection, init choiceIdx, focus
	useEffect(() => {
		setSelectedIndex(0);
		const init: Record<number, number> = {};
		displayItems.forEach((it, idx) => {
			if (it.choices) init[idx] = 0;
		});
		setChoiceIdx(init);
		listRef.current?.focus();
	}, [menuKey, displayItems]);

	// move up/down
	const moveSelection = (delta: number) => {
		setSelectedIndex(i => (i + delta + displayItems.length) % displayItems.length);
	};

	// spin left/right through choices
	const cycleChoice = (delta: 1 | -1) => {
		const item = displayItems[selectedIndex];
		if (!item.choices) return;
		const max = item.choices.length;
		const cur = choiceIdx[selectedIndex] || 0;
		const next = (cur + delta + max) % max;
		// update UI
		setChoiceIdx(ci => ({ ...ci, [selectedIndex]: next }));
		// notify Lua of new value
		if (item.export) {
			fetchNui('selectMenuItem', {
				export: item.export,
				isServer: item.isServer,
				args: [item.choices![next]],
			});
		}
	};

	// Enter / submenu / back / event
	const handleSelect = () => {
		const item = displayItems[selectedIndex];
		if (!item) return;
		if (item.menu) {
			fetchNui('selectMenuItem', { menu: item.menu });
		} else if (item.eventName) {
			fetchNui('selectMenuItem', {
				eventName: item.eventName,
				resource: item.resourceName,
				isServer: item.isServer,
				args: item.args,
			});
		}
	};

	// keyboard handler
	const onKey = (e: React.KeyboardEvent<HTMLUListElement>) => {
		switch (e.key) {
			case 'ArrowDown': moveSelection(1); e.preventDefault(); break;
			case 'ArrowUp': moveSelection(-1); e.preventDefault(); break;
			case 'ArrowLeft': cycleChoice(-1); e.preventDefault(); break;
			case 'ArrowRight': cycleChoice(1); e.preventDefault(); break;
			case 'Enter': handleSelect(); e.preventDefault(); break;
		}
	};

	if (!displayItems.length) return null;

	return (
		<div className={styles.container}>
			<ul
				ref={listRef}
				className={styles.menu}
				tabIndex={0}
				onKeyDown={onKey}
			>
				{displayItems.map((item, idx) => {
					// if it has choices, show current value
					const val = item.choices ? item.choices[choiceIdx[idx] || 0] : null;
					return (
						<li
							key={idx}
							className={`${styles.menu__item} ${idx === selectedIndex ? styles['menu__item--selected'] : ''
								}`}
							onClick={() => { setSelectedIndex(idx); handleSelect(); }}
						>
							{item.label}{val !== null ? `: ${val}` : ''}
						</li>
					);
				})}
			</ul>
		</div>
	);
};

export default Menu;
