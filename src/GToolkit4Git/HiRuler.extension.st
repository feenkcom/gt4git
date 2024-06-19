Extension { #name : #HiRuler }

{ #category : #'*GToolkit4Git' }
HiRuler >> gtElementForRow: i withColorStrategy: aColorStrategy [
	| column e each size |
	each := self nodes at: i.
	size := 10.
	column := 20.
	e := BlElement new
			height: size * 2;
			width: 100;
			border: (BlBorder paint: Color green width: 1);
			addChild: (BlElement new
					background: (aColorStrategy colorForNode: each);
					border: (BlBorder paint: (aColorStrategy colorForNode: each) width: 2);
					geometry: BlCircleGeometry new;
					size: size @ size;
					relocate: (each rulerPoint x * column - (size/2)) @ (size/2)).
	(self linksAtRow: i)
		do: [ :link | 
			| startX startY endX endY |
			startX := link origin rulerPoint x * column.
			endX := link target rulerPoint x * column.
			startY := (link origin rulerPoint y - i) * 2 * size + size.
			endY := (link target rulerPoint y - i) * 2 * size + size.
			e
				addChildFirst: (BlManhattanLineElement new
						border: (BlBorder paint: (aColorStrategy colorForLink: link) width: 2);
						cornerRadius: 5;
						beVertical;
						fromAnchor: (BlAbsolutePositionAnchor position: startX @ startY);
						toAnchor: (BlAbsolutePositionAnchor position: endX @ endY)) ].
	^ e
]

{ #category : #'*GToolkit4Git' }
HiRuler >> gtElementForValue: anObject [
	^ self
		gtElementForRow: (self nodeAtValue: anObject) rulerPoint y
		withColorStrategy: nil
]

{ #category : #'*GToolkit4Git' }
HiRuler >> gtView2For: aView [
	<gtView>
	| color |
	color := HiWheelColorStrategy new.
	color ruler: self.
	^ aView explicit
		title: 'Graph2';
		stencil: [ | list |
			list := BrColumnedList new .
			"list column
				title: 'Nodes';
				cellStencil: [ :i | self gtElementForRow: i value withColorStrategy: color ];
				width: 100."
			list column
				title: 'Row';
				cellStencil: [ BrLabel new
						aptitude: BrGlamorousLabelAptitude new;
						hFitContent;
						vFitContent ];
				dataBinder: [ :e :i | e text: i printString ];
				width: 50.
			list column
				title: 'Links';
				cellStencil: [ BrLabel new
						aptitude: BrGlamorousLabelAptitude new;
						hFitContent;
						vFitContent ];
				dataBinder: [ :e :i | 
					e
						text: (String
								streamContents: [ :s | 
									(self linksAtRow: i)
										do: [ :each | s nextPutAll: each pointString ]
										separatedBy: [ s space ] ]) ].	
			"list send: [ :i | self nodes at: i theValue ]."
			list addAptitude: BrColumnedListHeaderAptitude.
			list items: ( 1 to: self numberOfRows ).
			list ]
]

{ #category : #'*GToolkit4Git' }
HiRuler >> gtViewFor: aView [
	<gtView>
	| color |
	color := HiWheelColorStrategy new.
	color ruler: self.
	^ aView columnedList
		title: 'Graph';
		items: [ 1 to: self numberOfRows ];
		column: 'Nodes'
			stencil: [ :i | self gtElementForRow: i withColorStrategy: color ]
			width: 100;
		column: 'Row'
			text: [ :i | i ]
			width: 50;
		column: 'Links'
			text: [ :i | 
				String
					streamContents: [ :s | 
						(self linksAtRow: i)
							do: [ :each | s nextPutAll: each pointString ]
							separatedBy: [ s space ] ] ];
		send: [ :i | (self nodes at: i)	theValue ]
]
