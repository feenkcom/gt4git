Class {
	#name : #GtGitCommit,
	#superclass : #IceGitCommit,
	#instVars : [
		'lepiterWorkingCopy'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitCommit >> gtActionCheckoutFor: anAction [
	<gtAction>
	^ anAction dropdown
		label: 'Checkout';
		content: [ :aDropdown | 
			BrSimpleList new
				margin: (BlInsets all: 5);
				items: IceCheckoutStrategy allGtStrategies;
				itemStencil: [ BrLabel new hMatchParent
						aptitude: BrGlamorousLabelAptitude + BrGlamorousListItemAptitude ];
				itemDataBinder: [ :aLabel :aStrategy | 
					aLabel
						text: aStrategy gtDescription;
						when: BlClickEvent
							do: [ :_ | 
								aStrategy
									committish: self;
									lepiterWorkingCopy: self lepiterWorkingCopy;
									checkoutOn: self repository workingCopy.
								aDropdown fireEvent: BrDropdownHideWish new ] ] ]
]

{ #category : #accessing }
GtGitCommit >> lepiterWorkingCopy [
	^ lepiterWorkingCopy
]

{ #category : #accessing }
GtGitCommit >> lepiterWorkingCopy: aLepiterWorkingCopy [
	lepiterWorkingCopy := aLepiterWorkingCopy
]
