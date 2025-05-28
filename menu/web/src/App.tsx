// src/App.tsx
import React, { useState } from 'react';
import Menu, { MenuItem } from '@components/menu';
import { useNuiEvent } from '@utilities/utils';
const App: React.FC = () => {
	const [visible, setVisible] = useState(false);
	const [menuKey, setMenuKey] = useState<string>('main');
	const [menus, setMenus] = useState<Record<string, MenuItem[]>>({});

	useNuiEvent('openMenu', (data: any) => {
		const menuData = data.data;
		setMenuKey(menuData.menuKey);
		setMenus(menuData.menus);
		setVisible(true);
	});
	useNuiEvent('close', () => {
		setMenuKey('');
		setMenus({})
		setVisible(false);
	})

	if (!visible) return null;

	const currentItems = menus[menuKey] || [];

	return (
		<Menu
			items={currentItems}
			menuKey={menuKey}
		/>
	);
};

export default App;
