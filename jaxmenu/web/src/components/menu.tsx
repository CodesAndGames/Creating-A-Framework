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
}

interface MenuProps {
	items?: MenuItem[];
	menuKey?: string;
}

const Menu: React.FC<MenuProps> = ({ items = [], menuKey = 'main' }) => {
	const [selectedIndex, setSelectedIndex] = useState<number>(0);
	const listRef = useRef<HTMLUListElement>(null)
	// Define Back button item
	const backItem: MenuItem = {
		label: '← Back',
		eventName: 'menuBack',
		isServer: false,
		args: []
	};

	// Build displayItems: prepend back unless main menu
	const displayItems = menuKey === 'main' ? items : [...items, backItem];

	// Reset selection when menu or items change
	useEffect(() => {
		listRef.current?.focus();
		setSelectedIndex(0)
	}, [menuKey, items.length]);
	const handleClose = () => {
		fetchNui('close')
	}
	const handleKey = (e: React.KeyboardEvent<HTMLUListElement>) => {
		switch (e.key) {
			case 'ArrowDown':
				setSelectedIndex(i => (i + 1) % displayItems.length);
				e.preventDefault();
				break;
			case 'ArrowUp':
				setSelectedIndex(i => (i - 1 + displayItems.length) % displayItems.length);
				e.preventDefault();
				break;
			case 'Enter':
				handleSelect();
				e.preventDefault();
				break;
			case 'Backspace':
				handleClose();
				e.preventDefault();
				break;
		}
	};

	const handleSelect = () => {
		const item = displayItems[selectedIndex];
		if (!item) return console.error('no item');
		const { menu, eventName, isServer, args = [] } = item;
		fetchNui('selectMenuItem', { menu, eventName, isServer, args });
	};



	// If no items to display, render nothing
	if (!displayItems.length) return null;
	return (
		<div className={styles.container}>
			<ul
				ref={listRef}
				className={styles.menu}
				tabIndex={0}
				onKeyDown={handleKey}>
				{displayItems.map((item, idx) => (
					<li
						key={idx}
						className={`${styles.menu__item} ${idx === selectedIndex ? styles['menu__item--selected'] : ''}`}
						onClick={() => {
							setSelectedIndex(idx);
							handleSelect();
						}}
					>
						{item.label}
					</li>
				))}
			</ul>
		</div>
	);
};

export default Menu;
