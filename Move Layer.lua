--[[
	Move individual layer, selected layers, 
	or all of the selected group's layers.
--]]
local dlg = Dialog("Move Selection"); -- dialogue object
-- Function Definition
-- send an error alert easily
local function err(msg)
	return app.alert{title="Error", text=msg, buttons="OK" };
end
-- move all layers within a layer (good for groups)
local function recursive_move(v, dx, dy, visible_only)
	if v.isImage and (visible_only and v.isVisible) then
		for _, cel in ipairs(v.cels) do
			cel.position = cel.position + Point(dx, dy)
		end
	elseif v.isGroup then
		for _, v in ipairs(v.layers) do
			recursive_move(v, dx, dy, visible_only);
		end
	end
end
-- perform the move based on the data set in the dialogue object
local move = function()
	local dx = dlg.data.dx or 0;
	local dy = dlg.data.dy or 0;
	local selected_mode = dlg.data.selected or "Group";
	
	dlg:close(); -- don't need this anymore
	
	-- check if there's an active sprite
	local sprite = app.sprite
    if not sprite then
      return err("No active sprite");
    end
	
	-- check if there's an active layer
	local layer = app.layer
	if not layer then
      return err("No active layers");
	end
	
	-- logic to check if the layer's parent is a group or the sprite
	--local parent = layer.parent
    --local not_in_group = not parent or parent == layer.sprite;
	
	-- test the mode selected
	if(selected_mode == "Group") then
		-- group mode, but the layer isnt a group
		if not layer.isGroup then
			return err("Group mode selected, but the selected layer isn't a group")
		end
		-- iterate and move the layers inside the group
		for _, v in ipairs(layer.layers) do
			recursive_move(v, dx, dy, false)
		end
	elseif (selected_mode == "Visible Layers") then
		-- all visible layers in the sprite mode
		for i,v in ipairs(sprite.layers) do
			recursive_move(v, dx, dy, true)
		end
	else -- Active Layer
		-- only the selected layer
		recursive_move(layer, dx, dy, false)
	end
	
end
-- Dialogue Creation=
dlg
:separator("Move")
:number{ id="dx", text="0" }
:number{ id="dy", text="0" }
:separator("Move Mode")
:combobox 
{
	id="selected",
	option = "Group",
	options = { "Group", "Visible Layers", "Active Layer" }
}
:separator()
:button{ text="OK", onclick=move }
:newrow() -- necessary to make the dialogue box not look terrible
:button{ text="Cancel", onclick=function() dlg:close() end }
:show();