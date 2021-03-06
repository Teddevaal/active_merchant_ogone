require 'test_helper'

class OgoneHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @helper = Ogone::Helper.new('order-500','openminds', :amount => 900, :currency => 'EUR')
  end

  def test_basic_helper_fields
    assert_field 'PSPID', 'openminds'
    assert_field 'orderID', 'order-500'
    assert_field 'amount', '900'
    assert_field 'currency', 'EUR'
  end

  def test_customer_fields
    @helper.customer :first_name => 'Jan', :last_name => 'De Poorter', :email => 'ogone@openminds.be', :civility => 'M'
    assert_field 'CN', 'Jan De Poorter'
    assert_field 'EMAIL', 'ogone@openminds.be'
    assert_field 'CIVILITY', 'M'
  end
  
  def test_after_pay_fields
    @helper.after_pay :bill_first_name => 'Nick',
                      :bill_last_name => 'den Engelsman',
                      :bill_street_number => '1098',
                      :ship_first_name => 'Nick',
                      :ship_last_name => 'den Engelsman',
                      :ship_adress => 'Laan van Meerdervoort',
                      :ship_adress_number => '1098',
                      :ship_adress_zip => '2564AZ',
                      :ship_adress_city => 'Den Haag',
                      :ship_adress_country_code => 'NL',
                      :ship_dob => '23/04/1987'
    # Billing
    assert_field 'ECOM_BILLTO_POSTAL_NAME_FIRST', 'Nick'
    assert_field 'ECOM_BILLTO_POSTAL_NAME_LAST', 'den Engelsman'
    assert_field 'ECOM_BILLTO_POSTAL_STREET_NUMBER', '1098'
    # Shipping
    assert_field 'ECOM_SHIPTO_POSTAL_NAME_FIRST', 'Nick'
    assert_field 'ECOM_SHIPTO_POSTAL_NAME_LAST', 'den Engelsman'
    assert_field 'ECOM_SHIPTO_POSTAL_STREET_LINE1', 'Laan van Meerdervoort'
    assert_field 'ECOM_SHIPTO_POSTAL_STREET_NUMBER', '1098'
    assert_field 'ECOM_SHIPTO_POSTAL_POSTALCODE', '2564AZ'
    assert_field 'ECOM_SHIPTO_POSTAL_CITY', 'Den Haag'
    assert_field 'ECOM_SHIPTO_POSTAL_COUNTRYCODE', 'NL'
    assert_field 'ECOM_SHIPTO_DOB', '23/04/1987' 
  end
  
  def test_after_pay_lineitems_fields
    @helper.lineitems [{:id => "1234",:name => "Test product 1",:price => "2.00",:quantity => "1",:vat_code => "19%",:tax_included => "1"},
      {:id => "1235",:name => "Test product 2",:price => "1.00",:quantity => "1",:vat_code => "19%",:tax_included => "1"}]
    # Line item 1
    assert_field 'ITEMID01', '1234'
    assert_field 'ITEMNAME01', 'Test product 1'
    assert_field 'ITEMPRICE01', '2.00'
    assert_field 'ITEMQUANT01', '1'
    assert_field 'ITEMVATCODE01', '19%'
    assert_field 'TAXINCLUDED01', '1'
    # Line item 2
    assert_field 'ITEMID02', '1235'
    assert_field 'ITEMNAME02', 'Test product 2'
    assert_field 'ITEMPRICE02', '1.00'
    assert_field 'ITEMQUANT02', '1'
    assert_field 'ITEMVATCODE02', '19%'
    assert_field 'TAXINCLUDED02', '1'
  end
  
  def test_operation
    @helper.operation :payment
    assert_field 'operation', 'SAL'
    
    @helper.operation :auth
    assert_field 'operation', 'RES'
    
    @helper.operation 'SAL'
    assert_field 'operation', 'SAL'
  end

  def test_address_mapping
    @helper.billing_address :address1 => 'Zilverenberg 39',
                            :address2 => '',
                            :city => 'Ghent',
                            :zip => '9000',
                            :country  => 'BE'

    assert_field 'owneraddress', 'Zilverenberg 39'
    assert_field 'ownertown', 'Ghent'
    assert_field 'ownerZIP', '9000'
    assert_field 'ownercty', 'BE'
  end

  def test_unknown_mapping
    assert_nothing_raised do
      @helper.company_address :address => 'Zilverenberg 39'
    end
  end

  def test_setting_invalid_address_field
    fields = @helper.fields.dup
    @helper.billing_address :street => 'Zilverenberg'
    assert_equal fields, @helper.fields
  end
end
