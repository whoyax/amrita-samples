<?php

class DiscountManager implements IDiscountManager {
    private $discounts = array();
    private $unusedItems = array();
    private $order = null;

    public function addDiscount(IDiscount $discount) {
        $discount->setManager($this);
        $this->discounts[] = $discount;
    }

    public function markUsedItem(IProduct $item) {
        foreach ( $this->unusedItems as $key => $unusedItem ) {
            if ( $item === $unusedItem ) {
                unset( $this->unusedItems[$key] );
            }
        }
    }

    public function setOrder(IOrder $order) {
        $this->order = $order;
    }

    public function saveDiscountForProduct(Iproduct $product, $discount) {
        return $this->order->setDiscountForProduct($product, $discount);
    }

    public function getUnusedItems() {
        return $this->unusedItems;
    }

    public function getAllItems() {
        return $this->order->getItems();
    }

    public function applyDiscounts() {
        $this->unusedItems = $this->order->getItems();

        foreach ( $this->discounts as $discount ) {
            $discount->calculate($this->unusedItems);
        }
    }

    public function __construct(Array $discounts = array()) {
        foreach ( $discounts as $discount ) {
            $this->addDiscount($discount);
        }
    }
}